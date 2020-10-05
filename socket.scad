// module for just the socket part of the mayflash adapter
// https://www.amazon.com/Mayflash-GameCube-Controller-Adapter-Switch/dp/B00RSXRLUE
// really just the black plastic part at the tip

// renders vertically with the controller port facing "forward".
// the top _should_ line up with the precise edge of the ports PCB

$fn = 64;

// "socket" = the round part
socketWidth = ceil(16.93) + 0.5;
socketRadius = socketWidth/2;
socketDepth = ceil(3.8);
// "plate" = the bigger part that we're going to use to hold the things in place
plateWidth = ceil(17.88);
plateRadius = plateWidth/2;
plateDepth = 1.6;
// "extension" = how far back to pretend the socket goes for spacing/arrangement
extensionDepth = socketDepth;

module mayflashSocket() {
    rotate([-90, 0, 0]) union() {
        // socket + extension
        translate([plateRadius, plateRadius, 0])
            cylinder(d = socketWidth, h = socketDepth + plateDepth + extensionDepth);
        // plate (really a cylinder + a rect)
        translate([plateRadius, plateRadius, extensionDepth])
            cylinder(d = plateWidth, h = plateDepth);
        translate([0, 0, extensionDepth])
            cube([plateWidth, plateRadius, plateDepth]); 
    };
}

mayflashSocket();
