/*
    A Radio Mounting Tower for Ham Radios
    Author: joe@kt3i.com
    Date: October 31, 2017
    
    -- Updated: October 7, 2019
        - speed up the difference calculation

*/

// Arbitrary dimensions
thickness = 3; // Thicknesses of walls, etc.
quality=72; // "Roundness" of circles.
tolerances = 0.15; // Something to add for shrinkage
compensate = .6; // Multiplier "fudging" constant for shrinkage compensation
corner_radius = 5; // radius of tower's corners

// Screw dimensions
m4 = 4 + (2 * (tolerances + compensate)); // Diameter of M4 screw shaft
m5 = 5 + (2 * (tolerances + compensate)); // Diameter of M5 screw shaft
// Radio dimensions
radio_count = 3; // Number of radios on tower
radio_width = 150.5; // Width of radio
radio_height = 42; // Height of radio
radio_height_spaceing = 20; // % of radio height between each radio
radio_screw_spaceing = 50; // Spaceing between mounting screws on radio


//  ================  DO NOT EDIT BELOW THIS LINE  ================  \\ 

// Radio height + tolarence
radio_height_t = (radio_height + tolerances);

// Vertical spacing between radioa 
radio_vert_space = radio_height_t * (radio_height_spaceing/100);

// Tower Dimensions
tower_width = radio_width + (2 * (tolerances + thickness)); // Overall width od tower (X)
tower_height = radio_vert_space + radio_count * (radio_vert_space + radio_height_t) + (4 * thickness); // Overall height of tower (Y)
tower_depth = (1.5 * radio_screw_spaceing) + (2 * (thickness + tolerances + m4)); // Depth of tower (Z)

include <MCAD/boxes.scad>
$fn = quality;
    
difference(){
    // First we create the tower has a box with rounded corners
    roundedBox([tower_width, tower_height, tower_depth], corner_radius, true);
    
    // Height of Lowest row of screew holes
    low_screw_height = -tower_height / 2 + (2 * thickness) + (radio_height_t/2) + radio_vert_space;
    
    // Loop over all of the radio bays to add mounting screw holes
    for (radio = [0:radio_count-1]) {
        echo(radio=radio);
        //mounting_hole_y = base_offset + ((1 + 1.5 * radio) * (radio_height + tolerances));
        mounting_hole_y = low_screw_height  + radio * (radio_vert_space + radio_height_t);
        // Then we cut out the rear screw holes
        translate([0,mounting_hole_y,-radio_screw_spaceing / 2])
        rotate([0,90,0])
        cylinder(h=tower_width+1, r=m4 / 2, center=true);
        
        // Next the front screw "trench"
        translate([0,mounting_hole_y,radio_screw_spaceing / 2])
        rotate([0,90,0])
        hull(){
            translate([-radio_screw_spaceing / 8,0,0]) cylinder(h=tower_width+1, r=m4 / 2, center=true);
            translate([radio_screw_spaceing / 8,0,0]) cylinder(h=tower_width+1, r=m4 / 2, center=true);
        }   // end of hull
    }   // end of for
    
    // Remove the top and bottom mounting bracket slots
    rotate([90,0,0]) cylinder(h=tower_height + 1, r=m5/2, center=true); 
    q_rw = radio_width / 4;
    q_tw = tower_depth / 4;
    translate([-q_rw, 0, -q_tw]) mountingSlots();
    translate([-q_rw, 0,  q_tw]) mountingSlots();
    translate([ q_rw, 0, -q_tw]) mountingSlots();
    translate([ q_rw, 0,  q_tw]) mountingSlots();
    
    // Next we create the inner box and remove it from the outterbox
    roundedBox([tower_width - (2 * thickness), tower_height - ( 2 * thickness), tower_depth+1], corner_radius, true);
}   // end of difference


module mountingSlots(){
    rotate([90,0,0])
    hull(){ 
        translate([-radio_width/10,0,0])
            cylinder(h=tower_height+1, r=m5/2, center=true);
        translate([radio_width/10,0,0])
            cylinder(h=tower_height+1, r=m5/2, center=true);
    }
}   // mountSlots()