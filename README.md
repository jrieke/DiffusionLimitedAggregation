DiffusionLimitedAggregation
===========================

Simulation of 3D cluster formation through diffusion using Cython, NumPy and VPython.<br>
Diffusion limited aggregation (DLA) is a process whereby diffusive particles attach to each other and form highly fractal clusters (<a href="http://en.wikipedia.org/wiki/Diffusion-limited_aggregation">Wikipedia</a>). 
DLA occurs in many diffusion-controlled systems, e. g. at the formation of snow flakes. <br>
<br>
This program uses random particle walks to simulate DLA in three dimensions. The particles are created on a random spot surrounding the center and perform a random walk until they come close to another particle and attach.<br>
The alogrithm uses Cython (a Python package allowing C functionality inside Python) for speed-up and VPython for 3D visualization.<br>
<br>
Run src/run.py to start. Requires Python 3.3, NumPy, Cython and VPython.