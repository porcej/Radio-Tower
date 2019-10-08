/*
    A Base for Radio Mounting Tower for Ham Radios
    Author: porcej@gmail.com
    Date: November 6, 2017

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
radio_count = 2; // Number of radios on tower
radio_width = 150.5; // Width of radio
radio_height = 39.5; // Height of radio
radio_screw_spaceing = 50; // Spaceing between mounting screws on radio

// Tower Dimensions
tower_width = radio_width + (2 * (tolerances + thickness)); // Overall width od tower (X)
tower_height = radio_count * (1.75 * (radio_height + tolerances)) + (2 * thickness); // Overall height of tower (Y)
tower_depth = (1.5 * radio_screw_spaceing) + (2 * (thickness + tolerances + m4)); // Depth of tower (Z)

// Base Dimensions
base_depth = 2 * tower_depth;
base_height = 3 * (tolerances + thickness);
base_width = tower_width + 2 * (tolerances + thickness);


include <MCAD/boxes.scad>
$fn = quality;

difference(){
    towerBase();
    translate([0,0,thickness + tower_height / 2]) rotate([90,0,0]) solidRadioTower();
}   // end of difference

module towerBase(){
    hull(){
        translate([0,0,thickness / 2])
            roundedBox([base_width, base_depth, thickness], corner_radius, true);
        translate([0,0, base_height / 2])
            roundedBox([tower_width, tower_depth, base_height], corner_radius, true);
    }   // end of hull
    
}   // towerBase();

module solidRadioTower(){    
    roundedBox([tower_width, tower_height, tower_depth], corner_radius, true);
}   // solidRadioTower()



module radioTower(){    
    difference(){
        // First we create the tower has a box with rounded corners
        solidRadioTower();
        
        
        base_offset = -tower_height / 2 + thickness;   
        
        // Loop over all of the radio bays to add mounting screw holes
        for (radio = [0:radio_count-1]) {
            mounting_hole_y = base_offset + ((1 + 1.5 * radio) * (radio_height + tolerances));
            // Then we cut out the rear screw holes
            translate([0,mounting_hole_y,-radio_screw_spaceing / 2])
            rotate([0,90,0])
            cylinder(h=tower_width, r=m4 / 2, center=true);
            
            // Next the front screw "trench"
            translate([0,mounting_hole_y,radio_screw_spaceing / 2])
            rotate([0,90,0])
            hull(){
                translate([-radio_screw_spaceing / 8,0,0]) cylinder(h=tower_width, r=m4 / 2, center=true);
                translate([radio_screw_spaceing / 8,0,0]) cylinder(h=tower_width, r=m4 / 2, center=true);
            }   // end of hull
        }   // end of for
        
        // Remove the top and bottom mounting bracket slots
        rotate([90,0,0]) cylinder(h=tower_height, r=m5/2, center=true); 
        translate([-radio_width/4,0,-tower_height/4]) mountingSlots();
        translate([-radio_width/4,0,tower_height/4]) mountingSlots();
        translate([radio_width/4,0,-tower_height/4]) mountingSlots();
        translate([radio_width/4,0,tower_height/4]) mountingSlots();
        
        // Next we create the inner box and remove it from the outterbox
        roundedBox([tower_width - (2 * thickness), tower_height - ( 2 * thickness), tower_depth], corner_radius, true);
    }   // end of difference
}   // radioTower()


module mountingSlots(){
    rotate([90,0,0])
    hull(){ 
        translate([-radio_width/10,0,0])
            cylinder(h=tower_height, r=m5/2, center=true);
        translate([radio_width/10,0,0])
            cylinder(h=tower_height, r=m5/2, center=true);
    }
}   // mountSlots()