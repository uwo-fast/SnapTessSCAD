use <..\src\tess.scad>;
use <..\src\snap.scad>;
use <..\src\utils_viz.scad>;
use <..\src\utils_points.scad>;

// Params
radius = 1.5;
levels = 3;
overlap = 0.2;

// Example 1
snap(lvls=levels, r=radius, ol=overlap);