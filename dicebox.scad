$fn = 64;

// USER EDITABLE VARIABLES
// Usually the only thing you should need to adjust is the slot_edge if you have smaller or larger dice than I have designed for, or the magnet_width and magnet_depth depending on what size magnets you are using. If you are using large magnets (>8mm), you may need to adjust the case_edge_multiplier varaible to increase the amount of extra space around the slots.


// DICE SLOT PARAMETERS
{
// Length of one side of the hexagon slots - adjust this to fit your dice
slot_edge = 14.5;

// Depth of a slot on one side. This should be more than half the thickness of your dice
slot_depth = 13;

// Rounding on the corners of the slots
slot_corner_rad = 1;

// thickness of the walls between the slots
slot_spacing = 2;
}


// CASE PARAMETERS
{
// How many times larger the case is than the slots.
case_edge_multiplier = 3.35;

// Rounding of the case corners
case_corner_rad = 5;

// Tolerence - this is added to some calculations where a bit of offset is needed for tight fits etc.
tol = 0.4; 

// The thickness of the lid at the bottom of the slot
lid_floor_thickness = 2; 
    
outer_lid_thickness = 1.6;
}


// MAGNET PARAMETERS
{
magnet_width = 6; // Outer diameter of the magnet
magnet_depth = 2; // Thickness off the magnet
magnet_offset_raw = 3; // How far the edge off the magnet should be from the edge of the case
}

// IMAGE PARAMETERS
image_path = "./D20-Dice-Isometric-SVG-a9w9ie.svg";
image_depth = 1;
// keeps image proportional to case size
image_scale = slot_edge/30;


// CALCULATED PARAMETERS - DO NOT EDIT
{
    // Length of one outer side of the hexagon of the case - this updates automatically with the size of the dice
    case_edge = slot_edge*case_edge_multiplier;
    // Total thickness of one side of the case
    case_thickness = lid_floor_thickness + slot_depth + tol;
    // Calculated amount to move the magnets to get the desired offset
    magnet_offset = magnet_offset_raw + magnet_width/2;
        
    magnet_post_height = case_thickness-lid_floor_thickness;
    magnet_post_edge = 10;


// These variables are used for MATH - please don't touch them
slot_radius=sqrt(3)/2*slot_edge;
slot_short_diag=sqrt(3)*slot_edge;
slot_long_diag=2*slot_edge;
case_radius=sqrt(3)/2*case_edge;
}


// SHAPES
module fhex(wid){
    
    // Modified version of Thejollygrimreaper code from https://www.youtube.com/watch?v=KAKEk1falNg
    // Updated so that width = the width of one side of the hex rather than the short diagnoal, and so it renders a 2D shape that can be rounded before extrusion
    hull(){
        translate([0,0,0])
        square([wid,wid*sqrt(3)],center = true);
        translate([0,0,0])
        rotate([0,0,120])square([wid,wid*sqrt(3)],center = true);
    }
}

module logo() {
    linear_extrude(height = image_depth, center = true)
    scale (image_scale)
    rotate([180,0,0])
    import(file = image_path, center = true, dpi = 96);
    
}


// Base case modules
module case_base (xpos,ypos,zpos) {
      linear_extrude(case_thickness) offset(r=+case_corner_rad) offset(delta=-case_corner_rad) translate([xpos,ypos,zpos]) fhex(case_edge);
}

// Outer lid for the top
module outer_lid (xpos,ypos,zpos) {
    
    difference(){
        // Outer lid
        linear_extrude(case_thickness*1.5) offset(r=+case_corner_rad) offset(delta=-case_corner_rad) translate([xpos,ypos,zpos]) fhex(case_edge+outer_lid_thickness*2);
        
        // Slot to cut
        translate([xpos,ypos,zpos+lid_floor_thickness]) linear_extrude(case_thickness*1.5) offset(r=+case_corner_rad) offset(delta=-case_corner_rad) fhex(case_edge+tol);
        
        
        translate([xpos,ypos,zpos]) logo();
    }
}

module magnet_hole () {
    cylinder(h=magnet_depth+tol*2, r=magnet_width/2,center=true);
}

module magnet_holes(){
    zpos = case_thickness-magnet_depth/2;
    
    //TOP RIGHT
    translate([
        (case_edge-magnet_offset)*sin(30),
        (case_edge-magnet_offset)*sin(60),
        zpos]) 
    magnet_hole();
    
    // BOTTOM LEFT
    translate([
        -((case_edge-magnet_offset)*sin(30)),
        -((case_edge-magnet_offset)*sin(60)),
        zpos]) 
    magnet_hole();
    
    // TOP LEFT
    translate([
        -((case_edge-magnet_offset)*sin(30)),
        ((case_edge-magnet_offset)*sin(60)),
        zpos]) 
    magnet_hole();
    
    // BOTTOM RIGHT
    translate([
        ((case_edge-magnet_offset)*sin(30)),
        -((case_edge-magnet_offset)*sin(60)),
        zpos]) 
    magnet_hole();
    
    // MID RIGHT
    translate([
        case_edge- magnet_offset,
        0,
        zpos]) 
    magnet_hole();
    
    // MID LEFT
    translate([
        -(case_edge-magnet_offset),
        0,
        zpos]) 
    magnet_hole();
    
}

module magnet_post () {
    
    // To fit into the corner of the hex, we want to have a trapezoid with two 60 degree angles and two 120 degree angles
    
    hull(){
        translate([0,0,0]) cylinder(h=magnet_post_height, r=case_corner_rad/2,center=true);
        translate([magnet_post_edge,0,0]) cylinder(h=magnet_post_height, r=case_corner_rad/2,center=true);
        translate([(magnet_post_edge*sin(60))*tan(30),-(magnet_post_edge*sin(60)),0]) cylinder(h=magnet_post_height, r=case_corner_rad/2,center=true);
        translate([-(magnet_post_edge*sin(30)),-(magnet_post_edge*sin(60)),0]) cylinder(h=magnet_post_height, r=case_corner_rad/2,center=true);
    }    
}

module magnet_posts(){
    zpos = magnet_post_height/2 + lid_floor_thickness;
    
    // TOP LEFT
    translate([
        -((case_edge-tol)*sin(30)),
        ((case_edge-tol)*sin(60)),
        zpos]) 
    magnet_post();
    
    // TOP RIGHT
    translate([
        (case_edge-tol)*sin(30),
        (case_edge-tol)*sin(60),
        zpos]) 
    rotate([0,0,300]) magnet_post();
    
    // MID LEFT
    translate([
        -(case_edge-tol),
        0,
        zpos]) 
    rotate([0,0,60]) magnet_post();
    
    // MID RIGHT
    translate([
        case_edge-tol,
        0,
        zpos]) 
    rotate([0,0,240]) magnet_post();
    
    // BOTTOM LEFT
    translate([
        -((case_edge-tol)*sin(30)),
        -((case_edge-tol)*sin(60)),
        zpos]) 
    rotate([0,0,120]) magnet_post();
    
    // BOTTOM RIGHT
    translate([
        ((case_edge-tol)*sin(30)),
        -((case_edge-tol)*sin(60)),
        zpos]) 
    rotate([0,0,180]) magnet_post();
}

// BOTTOM OF CASE
module slot () {
    linear_extrude(slot_depth+tol*2)  offset(r=+slot_corner_rad) offset(delta=-slot_corner_rad) fhex(slot_edge) ;
}

module slots (){  
    slot();

    translate([
        -slot_edge*1.5 - slot_spacing ,
        -slot_radius - slot_spacing/2 ,
        0]) slot();
    
    translate([
        slot_edge*1.5 + slot_spacing,
        -slot_radius - slot_spacing/sqrt(3),
        0]) slot();
    
    translate([
        -slot_edge*1.5 - slot_spacing,
        slot_radius + slot_spacing/2,
        0]) slot();
    
    translate([
        slot_edge*1.5 + slot_spacing,
        slot_radius + slot_spacing/2,
        0]) slot();
    
    translate([0,
    slot_short_diag+slot_spacing,
    0])
        slot();
    
    translate([0,
    -slot_short_diag-slot_spacing,
    0])
        slot();    
}


module case_bottom (xpos,ypos,zpos){
    
    difference() {
        union(){
            case_base(xpos,ypos,zpos); 
            linear_extrude(case_thickness*0.5) offset(r=+case_corner_rad) offset(delta=-case_corner_rad) translate([xpos,ypos,zpos]) fhex(case_edge+outer_lid_thickness*2);
        }
        translate([xpos,ypos,zpos+(lid_floor_thickness+tol)]) slots();
        translate([xpos,ypos,zpos]) magnet_holes();
    }    
}

module case_bottom_open (xpos,ypos,zpos){
    
    difference() {
        union(){
            case_base(xpos,ypos,zpos); 
            linear_extrude(case_thickness*0.5) offset(r=+case_corner_rad) offset(delta=-case_corner_rad) translate([xpos,ypos,zpos]) fhex(case_edge+outer_lid_thickness*2);
        }
        hull(){translate([xpos,ypos,zpos+(lid_floor_thickness+tol)]) slots();}
        translate([xpos,ypos,zpos]) magnet_holes();
    }    
}

//TOP OF CASE
module top_slot (){
    
    rotate([0,0,30]) linear_extrude(case_thickness) offset(r=+case_corner_rad) offset(delta=-case_corner_rad) translate([xpos,ypos,zpos]) fhex(case_edge);
}
module case_top (xpos,ypos,zpos){
        union(){
            difference() {
                translate([xpos,ypos,zpos]) magnet_posts();
                translate([xpos,ypos,zpos]) magnet_holes();
                    
            }
            outer_lid(xpos,ypos,zpos);
        }
}

//RENDER
case_bottom (0,0,0);
case_top (case_edge*2.25,0,0);
//case_bottom_open (0,case_edge*2.25,0);
