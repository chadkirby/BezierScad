use <BezierScad.scad>;

BezArc([
  [-10,-1],
  [-10, -6],
  [-1, -1],
  [-5, -10],
  [-1,-10]
  ], [-1,-1], steps = 16, heightCtls = [1,2,10,2,1]);