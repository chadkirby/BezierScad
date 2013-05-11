use <BezierScad.scad>;
x = 25;

translate([7.5,0,0]) 
BezWall( [
  [0,0],
  [x/2, x],
  [x,0],
] , width = 1.5, height = 10, steps = 4, centered = true );

translate([37.5,0,0]) 
BezWall( [
  [0,0],
  [0, x], [x, x],
  [x,0],
] , width = 1.5, height = 10, steps = 6, centered = true );

translate([67.5,0,0]) 
BezWall( [
  [0,0],
  [0, x], [x/2, x], [x, x],
  [x,0],
] , width = 1.5, height = 10, steps = 8, centered = true );

translate([97.5,0,0]) 
BezWall( [
  [0,0],
  [0, x], [0, x], [x, x], [x, x],
  [x,0],
] , width = 1.5, height = 10, steps = 10, centered = true );

translate([127.5,0,0]) 
BezWall( [
  [0,0],
  [0, x], [0, x], [x/2, x], [x, x], [x, x],
  [x,0],
] , width = 1.5, height = 10, steps = 12, centered = true );

translate([157.5,0,0]) 
BezWall( [
  [0,0],
  [0, x], [0, x], [0, x], [x, x], [x, x], [x, x],
  [x,0],
] , width = 1.5, height = 10, steps = 14, centered = true );

BezWall([
  [-0.1,0],
  [-20, 0],
  [-25,25]
  ],  widthCtls = [10, 1], 
      heightCtls = [1, 5, 6, 35], 
      steps = 32,
      centered = true
);
translate([0,30,0])
BezWall([
  [-0.1,0],
  [-15, 0],
  [-15, 25],
  [-25,25]
  ],  
    width = 2, 
    heightCtls = [1, 35, 1], 
    steps = 16,
    centered = false
);

translate([-30,30,0])
BezWall([
  [-0.1,0],
  [-15, 0],
  [-15, 25],
  [-25,25]
  ],  
    widthCtls = [2, 10], 
    height = 5, 
    steps = 16,
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

translate([-10, -10,0])
BezArc([
  [-10,-1],
  [-10, -10],
  [-1,-10]
  ], [-1,-1], steps = 16, heightCtls = [1,10]);