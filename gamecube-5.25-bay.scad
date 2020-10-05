// module for adapting the board + sockets of the mayflash Wii U/PC gamecube adapter
// to a standard 5.25" drive bay slot, because why not
// https://www.amazon.com/Mayflash-GameCube-Controller-Adapter-Switch/dp/B00RSXRLUE
// inspired by https://www.thingiverse.com/thing:1948219 - the official adapter
// requires some _weird_ monkey business with drivers, and I'm not about that life

// renders with controller ports facing "front"

use <socket.scad>

$fn = 64;

socketPCBWidth = ceil(115.11);
socketPCBHeight = ceil(18.72);
socketPCBThickness = 1.3;
socketPCBInset = 16.75;
socketPlateWidth = 18;
socketSpacing = 12;
boardYOffset = 11;
boardZOffset = 5.7;
mainPCBWidth = 80.5;
mainPCBHeight = 36.2;

// back left, from top, relative to main board 
hole1X = 17;
hole1Y = 3.5;
// front left
hole2X = 26.3;
hole2Y = mainPCBHeight - 2.85;
// back right
hole3X = mainPCBWidth - 16.5;
hole3Y = hole1Y;
// front right
hole4X = mainPCBWidth - 25.7;
hole4Y = hole2Y;

screwPostDiameter = 4.2;
screwHoleDiameter = 1.95; // screws are actually around 2.05mm thick
screwLength = 8;

cordNeckWidth = 10;
cordNeckHeight = 6;
cordNeckThickness = 2.8;
cordCollarWidth = 14.5;
cordCollarHeight = 10;
cordCollarThickness = 2.3;

// bay dimensions sourced from https://assets.euchner.de/sirius/26066.jpg
// did you know a 5.25" drive front plate is actually around 5.825" wide?
// me neither. I hate everything.

bayFrontWidth = 148;
bayFrontHeight = 42.5;
bayFrontThickness = 2;
bayBaseThickness = 1.5;
bayBoxHeight = 41;
bayBoxWidth = 146;
bayHoleDiameter = 2.5; // M3 screws

// front bottom
bayHole1X = 52.5;
bayHole1Y = 10;
// front top
bayHole2X = bayHole1X;
bayHole2Y = 22;
// back bottom
bayHole3X = 132.5;
bayHole3Y = bayHole1Y;

bayDepth = 80;

moduleZOffset = (bayFrontHeight - socketPCBHeight)/2;

module driveBaySled() {
    // front
    translate([-bayFrontWidth/2, 0, 0])
        cube([bayFrontWidth, bayFrontThickness, bayFrontHeight]);
    // floor + sides
    translate([-bayBoxWidth/2, 0, 0]) difference() {
        cube([bayBoxWidth, bayDepth, bayBoxHeight]);
        // interior cutout
        translate([bayFrontThickness, bayFrontThickness, bayBaseThickness])
            cube([bayBoxWidth-2*bayFrontThickness, bayDepth, bayBoxHeight]);
        // mounting holes
        translate([-0.1, bayHole1X, bayHole1Y])
            rotate([0, 90, 0])
                cylinder(d = bayHoleDiameter, h = bayBoxWidth + 0.2);
        translate([-0.1, bayHole2X, bayHole2Y])
            rotate([0, 90, 0])
                cylinder(d = bayHoleDiameter, h = bayBoxWidth + 0.2);
        translate([-0.1, bayHole3X, bayHole3Y])
            rotate([0, 90, 0])
                cylinder(d = bayHoleDiameter, h = bayBoxWidth + 0.2);
        // angled cutout because why not cause problems for ourselves
        translate([-bayFrontThickness/2, bayDepth + bayFrontHeight/4, 0])
            rotate([45, 0, 0])
                cube(bayFrontWidth);
    };
}

module driveBaySledWithHoles() {
    difference() {
        driveBaySled();
        translate([-1.5*socketSpacing - 2*socketPlateWidth, -0.01, moduleZOffset + socketPCBHeight]) union() {
            for (i=[0:3]) {
                translate([i*socketPlateWidth + i*socketSpacing, 0, 0])
                    mayflashSocket();
            }
        }
    }
}

module socketPCBSupports() {
    supportWallThickness = 2;
    translate([(socketPCBWidth + 4)/-2, socketPCBInset - supportWallThickness - 0.5*socketPCBThickness, 0]) difference() {
        cube([socketPCBWidth + 4, 2*supportWallThickness + socketPCBThickness, socketPCBHeight/6 + moduleZOffset]);
        translate([-0.5, supportWallThickness, moduleZOffset]) {
            cube([socketPCBWidth + 5, socketPCBThickness, socketPCBHeight]);
        }
        translate([2 + socketPCBWidth/2 + socketSpacing/2, -0.5, moduleZOffset])
            cube([2*socketPlateWidth + socketSpacing, 2*supportWallThickness + socketPCBThickness + 1, socketPCBHeight]);
        translate([2 + socketPCBWidth/2 - socketSpacing*1.5 - socketPlateWidth*2, -0.5, moduleZOffset])
            cube([2*socketPlateWidth + socketSpacing, 2*supportWallThickness + socketPCBThickness + 1, socketPCBHeight]);
    }
}

module screwPost(x, y) {
    translate([x, mainPCBHeight - y, 0]) difference() {
        cylinder(d = screwPostDiameter, h = moduleZOffset + boardZOffset);
        translate([0, 0, moduleZOffset + boardZOffset - screwLength])
            cylinder(d = screwHoleDiameter, h = screwLength * 2);
    }
}

module cableSupport() {
    supportWall = 2;
    supportWidth = cordCollarWidth + 2*supportWall;
    supportDepth = cordCollarThickness + 2*supportWall;
    translate([-supportWidth/2, socketPCBInset + socketPCBThickness + boardYOffset + mainPCBHeight + 4, 0]) difference () {
        cube([supportWidth, supportDepth, moduleZOffset + boardZOffset + cordCollarHeight]);
        // collar inset
        translate([supportWall, supportWall, moduleZOffset + boardZOffset])
            cube([cordCollarWidth, cordCollarThickness, cordCollarWidth]);
        // cables cutouts
        translate([supportWall + (cordCollarWidth - cordNeckWidth)/2, -0.5, moduleZOffset + boardZOffset])
            cube([cordNeckWidth, supportDepth + 1, cordCollarWidth]);
    }
}

// cut out some base material for time/material saving
module materialSaverCutout() {
    cutoutXStart = mainPCBWidth / 2 - 10;
    cutoutYStart = socketPCBInset + socketPCBThickness/2 + 2;
    translate([cutoutXStart, cutoutYStart, -0.5])
        cube([bayBoxWidth/2 - 5 - cutoutXStart, bayDepth - 10 - cutoutYStart, bayBaseThickness + 1]);
}

// whole thing assembled
difference() {
    union() {
        driveBaySledWithHoles();
        socketPCBSupports();
        translate([-mainPCBWidth/2, socketPCBInset + socketPCBThickness + boardYOffset, 0]) union() { 
            screwPost(hole1X, hole1Y);
            screwPost(hole2X, hole2Y);
            screwPost(hole3X, hole3Y);
            screwPost(hole4X, hole4Y);
        };
        cableSupport();
    };
    materialSaverCutout();
    mirror([1, 0, 0]) materialSaverCutout();
}