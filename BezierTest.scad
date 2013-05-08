use <BezierScad.scad>;
x = 25;

translate([0,0,0]) linear_extrude(height = 5) 
BezLine( [
  [0,0],
  [x/2, 5],
  [x,0],
] , [1.5], 3 );

translate([27,0,0]) linear_extrude(height = 5) 
BezLine( [
  [0,0],
  [0, x], [x, x],
  [x,0],
] , [1.5], 3 );

translate([54,0,0]) linear_extrude(height = 5) 
BezLine( [
  [0,0],
  [0, x], [x/2, 5], [x, x],
  [x,0],
] , [1.5], 3 );

translate([81,0,0]) linear_extrude(height = 5) 
BezLine( [
  [0,0],
  [0, x], [0, x], [x, x], [x, x],
  [x,0],
] , [1.5], 4 );

translate([108,0,0]) linear_extrude(height = 5) 
BezLine( [
  [0,0],
  [0, x], [0, x], [x/2, 5], [x, x], [x, x],
  [x,0],
] , [1.5], 4 );

translate([135,0,0]) linear_extrude(height = 5) 
BezLine( [
  [0,0],
  [0, x], [0, x], [0, x], [x, x], [x, x], [x, x],
  [x,0],
] , [1.5], 4 );

BezWall([
  [-0.1,0],
  [-20, 0],
  [-25,25]
  ],  widthCtls = [10, 4], 
      heightCtls = [1, 5, 6, 35], 
      resolution = 5,
      centered = true
);

linear_extrude(height = 5) 
BezLine([
  [0,-10], [5, -20], [0,-30]
  ], width = [5, 10], resolution = 2, centered = true);

linear_extrude(height = 5) 
BezLine([
  [0,10], [5, 20], [0,30]
  ], width = [5, 10], resolution = 3, centered = false);

