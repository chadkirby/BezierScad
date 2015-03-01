use <BezierScad.scad>;

BezArc([
  [-10,-1],
  [-10, -6],
  [-1, -1],
  [-5, -10],
  [-1,-10]
  ], [-1,-1], steps = 16, heightCtls = [1,2,10,2,1]);

translate([25,0,0]) 
    BezArc([
      [-10, 0],
      [-10, -6],
      [-1, -1],
      [-5, -10],
      [0,-10]
      ], focalPoint = [0,0], steps = 30, height = 10);