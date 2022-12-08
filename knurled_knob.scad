// Knurled knob with optional polygonal, circular, or D-shaped hole
// David O'Connor  9 June 2022
// CC-BY-4.0


/*[Overall Knob Shape]*/
// Diameter
diam = 25.4;
// height
h = 12.7; 
// bevel face width
bev = 3;  

/*[Parameters for Optional Hole]*/
// True if you want a hole
hole = true; // [true:mounting hole, false:no mounting hole]
// Type of hole
holeType = 1;  // [1:circular, 4:square, 6:hexagonal]
// Hole diameter, or distance across flats for square or hexagonal hole
holeDim = 11.1;  
// Hole depth
holeDepth = 6; 
// Fraction of circular hole to clip (for accommodating "D" shaped shafts, for example)
holeClip = 0;  // [0.0:0.05:1.0]
// Fit clearance
fitClearance = 0.15;

/*[Optional Thru Hole]*/
// True if you want an extra thru hole
optionalThruHole = false;
// Diameter of the thru hole
thruHoleDiam = 11.1;

/*[Parameters for Knurling]*/  
// approximate groove pitch
grooveSize = 1.5;
// groove depth
gh = 1;   

/*[Hidden]*/
eps = 0.02; // small distance to help avoid CSG ambiguities
$fn = 90;   // number of fragments, higher for finer detail

////////////////////////////////////////////////////////////////////////////////////

// These are the only variables used globally.
r = diam / 2;
n = 2 * floor(PI * diam / grooveSize / 2);

translate([0, 0, h]) {
    rotate([180, 0, 0]) {
        difference() {
            intersection() {
                intersection() {
                    bev_cyl(h, r = r, bevel = bev);
                    knurling();
                }
                scale([-1, 1, 1]) knurling();
            }
            if (hole) { 
                union() {
                    hole_cutout(holeDim/2, holeType, holeDepth, fitClearance, holeClip); 
                    if (optionalThruHole) {
                        cylinder(h = 2*h, r = thruHoleDiam / 2, center = true);
                    }
                }
            }
        }
    }
}

module knurling() {
    points = [ for (k = [1:n]) [(r +  gh * ((k % 2) * 2 - 1)) * cos(k/n*360), (r + gh * ((k % 2) * 2 - 1))  * sin(k/n*360)] ];
    twistFactor = 60;  // A value of 60 makes the knurling to be about 45 degrees.
    linear_extrude(height = h, convexity = 10, twist = h / r * twistFactor) {
        polygon(points);
    }
}

module bev_cyl(h, r, bevel = 0) {
    b = bevel / sqrt(2);
    rotate_extrude() {
        polygon( points = [ [0, 0], [r-b, 0], [r, b], [r, h-b], [r-b, h], [0, h] ]);
    }
}

module hole_cutout(radius, type, depth, clearance, offset = 0) {
    translate([0, 0, -eps]) {
        if (type == 1) {  
            difference() {
                cylinder (h = depth + eps, r = radius + clearance);           
                translate([r + clearance + (0.5 - offset)  * 2 * radius, 0, 0]) {
                    cube([2*r, 2*r, 3*h], center = true);
                }      
            }               
        }
        else {
            r2 = (radius + clearance) / cos(180 / type);
            linear_extrude(depth + eps) {
                points = [ for (k = [1:type]) [ r2 * cos(360 * k / type), r2 * sin(360 * k / type) ] ];
                polygon(points);                  
            }
        }
    }
}
   