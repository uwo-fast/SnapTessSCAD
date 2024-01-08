/*
 * Title: Point Calculation Utilities
 * Author: [Your Name]
 * Organization: [Your Organization]
 * 
 * License: [Specify License]
 *
 * Description:
 *   This OpenSCAD script, named 'point-calculation-utils.scad', includes a collection 
 *   of functions designed for calculating and manipulating points. The script offers 
 *   functionalities such as sorting points, calculating row heights, generating 
 *   triangulated center points, and filtering points. These utilities are essential 
 *   for geometric manipulations and can be used in a variety of design and modeling contexts.
 *
 * Dependencies:
 *   sorted-nop\sorted.scad - Required for sorting functionality.
 *
 * Usage Notes:
 *   To use these functions, include this script in your OpenSCAD project. You can 
 *   apply these functions to manipulate point data in your models, such as sorting 
 *   points, finding unique points, or filtering based on specific criteria. Ensure 
 *   that 'sorted-nop\sorted.scad' is accessible in your project directory.
 *
 * Parameters:
 *   centers - Array of point coordinates.
 *   sorted_centers - Array of sorted point coordinates.
 *   point - A single point coordinate.
 *   list - A list of points for comparison or filtering.
 *   tolerance - A small value to account for numerical precision issues.
 *
 * Revision History:
 *   [YYYY-MM-DD] - Initial version.
 *   [YYYY-MM-DD] - Subsequent updates with details.
 */


use <sorted-nop\sorted.scad>

/*

This script is for functions related to point calculations

*/


EPSILON = 1e-3;

// Function to sort  centers
function sort_centers(centers) =
    sorted(centers, key = function(p) [p[1], p[0]]);  // Sort by y, then x

// Function to calculate the point row's height
function point_row_height(sorted_centers) =
    let (
        row_heights = [
            for (i = [1 : len(sorted_centers) - 1])
                if (sorted_centers[i][1] != sorted_centers[i - 1][1])
                    abs(sorted_centers[i][1] - sorted_centers[i - 1][1])
        ]
    )
    (len(row_heights) > 0) ? row_heights[0] : undef;

// Function to calculate triangulated centers
function triangulated_center_points(sorted_centers) =
    let (
        row_height = point_row_height(sorted_centers)
    )
    let (
        tri_centers = []
    )
    concat(  // Flatten the array and filter out empty entries
        [
            for (i = [0 : len(sorted_centers) - 2]) 
                for (j = [0 : len(sorted_centers) - 1])
                    let (
                        p1 = sorted_centers[i],
                        p2 = sorted_centers[i + 1],
                        p3 = sorted_centers[j]
                    )
                    if (abs(p1[1] - p2[1]) < EPSILON && abs(p3[1] - p1[1] - row_height) < EPSILON && p3[0] > p1[0] && p3[0] < p2[0])
                        ([(p1[0] + p2[0] + p3[0]) / 3, (p1[1] + p2[1] + p3[1]) / 3])
        ]
    );

// Function to check if two points are equal within a tolerance
function points_equal(p1, p2, tolerance=EPSILON) =
    let(
        comparisons = [for(i = [0:len(p1)-1]) abs(p1[i] - p2[i]) < tolerance]
    )
    // Manually check if all comparisons are true
    len([for(comp = comparisons) if (comp) true]) == len(comparisons);

// Function to check if any point in a list equals the given point
function is_point_in_list(point, list, tolerance=EPSILON) =
    let(
        equal_points = [for(p = list) points_equal(p, point, tolerance)]
    )
    len([for(eq = equal_points) if (eq) true]) > 0;

// Function to filter out certain centers
function filter_center_points(centers, filter_list, tolerance=EPSILON) =
    [for(center = centers) if (!is_point_in_list(center, filter_list, tolerance)) center];
