'''
Simulate diffusion limited aggregation (DLA) in 3D through random particle walks inside a cube.
Show a 3D visualization of the output using VPython.

Cython file, must be compiled and run through accompanying 'run.py'.
'''


from visual import sphere, color, rate, scene, ring, points
import numpy as np
from libcpp cimport bool
from libc.stdlib cimport rand, srand
from libc.math cimport sqrt
cdef extern from "stdlib.h":
    int RAND_MAX


###################################
# Parameters
###################################

cdef int n = 20  # Cube size
cdef float max_distance = 0  # Initial radius of the creation sphere
particle_size = 3
seeds = [(n/2, n/2, n/2)]

###################################


array = np.zeros((n, n, n))
for s in seeds:
    array[s] = 1
cdef int particle_num = 2

# Plot window
scene.center = (n/2, n/2, n/2)
scene.range = n * 2/3

# Numpy randoms, used for initial values
cdef int random_index = 0
cdef int random_size = 1000000
random = np.random.random(random_size)

# C randoms, used for random walk
cdef float RAND_MAX_float = float(RAND_MAX)
srand(np.random.randint(1000))  # set seed by numpy random

# Cython definitions
cdef int x, x_plus, x_minus, y, y_plus, y_minus, z, z_plus, z_minus, r_int, lower_bound, upper_bound
cdef float distance
cdef int reached_end = 0
cdef int particle_attached


print 'Initialised, starting above radius', max_distance
while reached_end == 0:

    if (particle_num % 1000) == 0:
        print(max_distance)

    # Create new numpy randoms if all have been used
    if random_index + 2 >= random_size:
        random = np.random.random(random_size)
        random_index = 0
        print('New random numbers generated.')

    # Set random start position on sphere
    phi = random[random_index] * 2. * np.pi
    theta = random[random_index+1] * np.pi
    random_index += 2
    r = min(max_distance + 2, n/2)
    r_int = int(r)
    z = n/2 + int(r * np.sin(theta) * np.cos(phi))
    x = n/2 + int(r * np.sin(theta) * np.sin(phi))
    y = n/2 + int(r * np.cos(theta))

    # Bounds for periodicity
    lower_bound = n/2 - r_int
    upper_bound = n/2 + r_int


    particle_attached = 0
    while particle_attached == 0:

        # Neighboring fields
        # TODO: minor offsets for some values
        x_plus = (x+1-lower_bound) % (2*r_int) + lower_bound
        x_minus = (x-1-lower_bound) % (2*r_int) + lower_bound
        y_plus = (y+1-lower_bound) % (2*r_int) + lower_bound
        y_minus = (y-1-lower_bound) % (2*r_int) + lower_bound
        z_plus = (z+1-lower_bound) % (2*r_int) + lower_bound
        z_minus = (z-1-lower_bound) % (2*r_int) + lower_bound

        # Attach if particle on neighboring field, else perform random walk
        if array[x_plus, y, z] != 0 or array[x_minus, y, z] != 0 or array[x, y_plus, z] != 0 or array[x, y_minus, z] != 0 or array[x, y, z_plus] != 0 or array[x, y, z_minus] != 0:
            array[x, y, z] = particle_num
            particle_num += 1
            distance = sqrt((x-n/2)**2 + (y-n/2)**2 + (z-n/2)**2)
            if distance >= n/2 -1:
                reached_end = 1
            if distance > max_distance:
                max_distance = distance
            particle_attached = 1
        else:
            x = x_plus if (rand() / RAND_MAX_float) < 0.5 else x_minus
            y = y_plus if (rand() / RAND_MAX_float) < 0.5 else y_minus
            z = z_plus if (rand() / RAND_MAX_float) < 0.5 else z_minus


print('Plotting')

list_of_points = []
list_of_colors = []

# Sort all particles into 'list_of_points' and their color - resembling particle number - into 'list_of_colors'
for i in range(n):
    for j in range(n):
        for k in range(n):
            if array[i, j, k] != 0:
                list_of_points.append((i, j, k))
                dist = np.sqrt((i-n/2)**2 + (j-n/2)**2 + (k-n/2)**2)
                list_of_colors.append(color.hsv_to_rgb( (0.3 * array[i, j, k] / particle_num, 1., 1.) ))

points(pos=seeds, size=2*particle_size, color=color.white)
points(pos=list_of_points, size=particle_size, color=list_of_colors)
