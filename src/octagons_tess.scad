/**
* octagons.scad
*
* Adapted from the hexagons module by Justin Lin, 2017
* Modifications made by Cameron K. Brooks, 2024
*
* License: https://opensource.org/licenses/lgpl-3.0.html
*
* Original hexagons module at: https://openhome.cc/eGossip/OpenSCAD/lib3x-hexagons.html
*
**/



// Function to calculate octagon centers for both levels and grid
function octagon_centers(radius, levels, spacing=undef, n=undef, m=undef, rotate=true) =
    let(
        // Common calculations
        side_length = (radius * 2) / (sqrt(4 + 2 * sqrt(2))),
        segment_length = side_length / sqrt(2),
        total_width = side_length * (1 + sqrt(2)),
        tip = rotate ? segment_length : (side_length / 2) * sqrt(2 - sqrt(2)) * 2,
        shift = rotate ? total_width : radius * 2,
        offset = shift - tip,

        // Function for generating points in a grid pattern
        generate_grid_points = function(n, m, offset_step) 
            [for(i = [0:n-1], j = [0:m-1]) [i * offset_step, j * offset_step]],

        // Function for generating points based on levels
        octagons_pts = function(oct_datum, offset_step, center_offset) 
            let(
                tx = oct_datum[0][0],
                ty = oct_datum[0][1],
                n_pts = oct_datum[1],
                offset_xs = [for(i = 0; i < n_pts; i = i + 1) i * offset_step + center_offset]
            )
            [for(x = offset_xs) [x + tx, ty]]
    )
    (!is_undef(n) && !is_undef(m)) ?
        // Grid pattern case
        generate_grid_points(n, m, total_width) :
        // Levels case
    let(
        beginning_n = 2 * levels - 1,
        rot = rotate ? 22.5 : 0,
        r_octagon = radius - spacing / 2,
        side_length = (radius * 2) / (sqrt(4+2*sqrt(2))),
        segment_length = side_length / sqrt(2),
        total_width = side_length*(1+sqrt(2)),
        tip = rotate ? segment_length : (side_length / 2) * sqrt(2 - sqrt(2)) * 2,
        shift = rotate ? total_width : radius * 2,
        offset = shift - tip,
        offset_step = 2 * offset,
        center_offset = -(offset * 2 * (levels - 1)),

        octagons_pts = function(oct_datum) 
            let(
                tx = oct_datum[0][0],
                ty = oct_datum[0][1],
                n = oct_datum[1],
                offset_xs = [for(i = 0; i < n; i = i + 1) i * offset_step + center_offset]
            )
            [for(x = offset_xs) [x + tx, ty]],

        upper_oct_data = levels > 1 ? 
            [for(i = [1:levels * 2])
                let(
                    x = offset * i,
                    y = offset * i,
                    n = beginning_n - i
                ) [[x, y], n]
            ] : [],

        lower_oct_data = levels > 1 ? 
            [for(oct_datum = upper_oct_data)
                [[oct_datum[0][0], -oct_datum[0][1]], oct_datum[1]]
            ] : [],

        total_oct_data = [[[0, 0], beginning_n], each upper_oct_data, each lower_oct_data],

        local_hexagon_centers = []
    )
    let(
        centers = [for(oct_datum = total_oct_data)
            let(pts = octagons_pts(oct_datum))
            [for(pt = pts) pt]
        ]
    ) concat([for(c = centers) each c]);    

    
// Module to create octagons with optional color gradient
module octagons(radius,levels,  spacing=0, rotate=true, order=1, octagon_centers=undef, color_scheme=undef, alpha=undef) {
    if (is_undef(octagon_centers)) {
        octagon_centers = calculate_octagon_centers(radius, levels, spacing, rotate, order);
    }

    // Determine the range of the center points for normalization
    min_x = min([for(center = octagon_centers) center[0]]);
    max_x = max([for(center = octagon_centers) center[0]]);
    min_y = min([for(center = octagon_centers) center[1]]);
    max_y = max([for(center = octagon_centers) center[1]]);

    for(center = octagon_centers) {
        normalized_x = (center[0] - min_x) / (max_x - min_x);
        normalized_y = (center[1] - min_y) / (max_y - min_y);

        color_val = get_gradient_color(normalized_x, normalized_y, color_scheme);

        // Apply color gradient only if color_scheme is specified
        if (!is_undef(color_scheme)) {
            color_val = [0.9, 0.9, 0.9];
        }

        color(color_val, alpha = alpha)
        translate([center[0], center[1], 0]) 
            rotate([0, 0, rotate ? 22.5 : 0]) circle(radius - spacing / 2, $fn = 8*order);
        
    }
}

