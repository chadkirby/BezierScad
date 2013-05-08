###
  Coffeescript generator for Bezier functions for OpenScad
  Sources/Inspirations:
    http://en.wikipedia.org/wiki/Bézier_curve
    http://www.cs.mtu.edu/~shene/COURSES/cs3621/NOTES/spline/Bezier/bezier-der.html
    http://www.thingiverse.com/thing:8443

Copyright (c) 2013 Chad Kirby

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
###

binomialCoeffs = (n) ->
  cfs = [1]
  for k in [0...n]
    cfs.push (cfs[k] * (n-k)) / (k+1)
  cfs

ptFn = (order, indent = '  ') ->
  coeffs = binomialCoeffs(order-1)
  # console.log coeffs
  args = ["t", "ctls"]
  scad = for cf, i in coeffs
    itpow = coeffs.length - i - 1
    s = "("
    s += "#{cf} * " if cf > 1
    s += "pow(t, #{i}) * " if i > 1
    s += "t * " if i is 1
    s += "pow(1-t, #{itpow}) * " if itpow > 1
    s += "(1-t) * " if itpow is 1
    # s += "p[#{i}][n])"
    s += "ctls[#{i}]"
    s += ")"
    # s += "p#{i})"
    # args.push "p#{i}"
    s

  """
  function BezI#{order}(#{args.join ', '}) =
    #{scad.join( " +\n#{indent}") + "\n#{indent};\n"}
  """

orderMax = 8
maxLineResolution = 6

bezScad = """
/* 
  Bezier functions for OpenScad
  Generated from #{require('path').basename(process.argv[1])} from #{process.platform} at #{new Date()}
  Supports Bezier interpolation with 1-#{orderMax} controls
  Sources/Inspirations:
    http://en.wikipedia.org/wiki/Bézier_curve
    http://www.cs.mtu.edu/~shene/COURSES/cs3621/NOTES/spline/Bezier/bezier-der.html
    http://www.thingiverse.com/thing:8443

Copyright (c) 2013 Chad Kirby

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/


"""


bezScad += """

module BezLine(ctlPts, width = [1], resolution = 4, centered = false, showCtls = true) {
  hodoPts = hodograph(ctlPts);
  if (showCtls) {
    for (pt = ctlPts) {
      % translate([pt[0], pt[1], 0]) circle(1);
    }
  }

""" + (
  for resolution in [2..maxLineResolution]
    steps = Math.pow(2, resolution)
    pts = for i in [0...steps]
      "PointAlongBez(#{i}/#{steps-1}, ctlPts)"

    for i in [steps-1..0]
      pts.push "PerpAlongBez(#{i}/#{steps-1}, ctlPts, dist = BezI(#{i}/#{steps-1}, width), hodograph = hodoPts)"

    cpts = for i in [0...steps]
      "PerpAlongBez(#{i}/#{steps-1}, ctlPts, dist = BezI(#{i}/#{steps-1}, width)/2, hodograph = hodoPts)"

    for i in [steps-1..0]
      cpts.push "PerpAlongBez(#{i}/#{steps-1}, ctlPts, dist = BezI(#{i}/#{steps-1}, width)/-2, hodograph = hodoPts)"

    """
    if (resolution == #{resolution}) {
      if (centered) {
        polygon([
          #{cpts.join(', ')}
        ]);
      } else {
        polygon([
          #{pts.join(', ')}
        ]);
      }
    }
    """
).join(' else ').replace(/^/gm,'  ') + """

  }
"""


bezScad += """


module BezWall(ctlPts, widthCtls = [1], heightCtls = [1], resolution = 4, centered = false, showCtls = true) {
  hodoPts = hodograph(ctlPts);
  if (showCtls) {
    for (pt = ctlPts) {
      % translate([pt[0], pt[1], 0]) circle(1);
    }
  }
  steps = pow(2, resolution) - 1; // max res 6
  for(step = [steps:1])
  {
    assign(
      t1 = step/steps, 
      t0 = (step-1)/steps
    ) {
      linear_extrude( height = BezI(t0, heightCtls) , convexity = 10) 
      if (centered) {
        assign(wid0 = BezI(t0, widthCtls)/2, wid1 = BezI(t1, widthCtls)/2) {
          polygon([
            PerpAlongBez(t1, ctlPts, dist = wid1, hodograph = hodoPts),
            PerpAlongBez(t0, ctlPts, dist = wid0, hodograph = hodoPts),
            PerpAlongBez(t0, ctlPts, dist = -wid0, hodograph = hodoPts),
            PerpAlongBez(t1, ctlPts, dist = -wid1, hodograph = hodoPts),
          ]);
        }
      } else {
        polygon([
          PointAlongBez(t1, ctlPts),
          PointAlongBez(t0, ctlPts),
          PerpAlongBez(t0, ctlPts, dist = BezI(t0, widthCtls), hodograph = hodoPts),
          PerpAlongBez(t1, ctlPts, dist = BezI(t1, widthCtls), hodograph = hodoPts),
        ]);
      }
    }
  }
}


""" 

bezScad += """
function PointAlongBez(t, ctlPts) = 
  
""" + (
  for order in [1..orderMax]
    """
    len(ctlPts) == #{order} ? PointAlongBez#{order}(t, ctlPts) :
    """
).join(' \n  ') + '\n  [];\n\n'

bezScad += """
function BezI(t, ctls) = 
  
""" + (
  for order in [1..orderMax]
    """
    len(ctls) == #{order} ? BezI#{order}(t, ctls) :
    """
).join(' \n  ') + '\n  [];\n\n'

for order in [1..orderMax]
  argsx = ("ctlPts[#{i}][0]" for i in [0...order]).join ', '
  argsy = ("ctlPts[#{i}][1]" for i in [0...order]).join ', '
  bezScad += """
  function PointAlongBez#{order}(t, ctlPts) = [ 
    BezI#{order}(t, [#{argsx}]), 
    BezI#{order}(t, [#{argsy}]) 
  ];\n
  """

bezScad +=  """

function PerpAlongBez(t, ctlPts, dist = 1, hodograph = []) = 
  
""" + (
  for order in [2..orderMax]
    """
    len(ctlPts) == #{order} ? PerpAlongBez#{order}(t, ctlPts, dist, hodograph) :
    """
).join(' \n  ') + '\n  [];\n\n'

for order in [2..orderMax]
  bezScad += """
  function PerpAlongBez#{order}(t, ctlPts, dist = 1, hodograph = []) = 
    pSum( 
      PointAlongBez#{order}(t, ctlPts), 
      rot90cw( 
        normalize( 
          PointAlongBez#{order-1}( t, (len(hodograph) > 1) ? hodograph : hodograph(ctlPts) ),
          dist 
        ) 
      )
    );
  

  """

hodographs = for order in [2..orderMax]
  pts = for i in [0...order-1]
    "pDiff(p[#{i+1}], p[#{i}])"
  """
  len(p) == #{order} ? 
      [ #{pts.join(', ')} ] : 
  """

bezScad += """

function hodograph(p) = 
  
""" + hodographs.join(' \n  ') + '\n  [];'  


bezScad += '\n\n' + (ptFn(order) for order in [1..orderMax]).join('\n') + """

  function x(p) = p[0];
  function y(p) = p[1];
  function dx(p1, p2) = x(p1) - x(p2);
  function dy(p1, p2) = y(p1) - y(p2);
  function sx(p1, p2) = x(p1) + x(p2);
  function sy(p1, p2) = y(p1) + y(p2);

  function dist(p1, p2 = [0,0]) = sqrt( pow( dx(p1,p2), 2) + pow( dy(p1,p2), 2) );
  function normalize(p, n = 1) = pScale( p, n / dist( p ) );

  function pSum(p1, p2) = [sx(p1, p2), sy(p1, p2)];
  function pDiff(p1, p2) = [dx(p1, p2), dy(p1, p2)];
  function pScale(p, v) = [x(p)*v, y(p)*v];
  
  function rot90cw(p) = [y(p), -x(p)];
  function rot90ccw(p) = [-y(p), x(p)];
  function rot(p, a) = [
    x(p) * cos(a) - y(p) * sin(a),
    x(p) * sin(a) - y(p) * cos(a),
  ];
  function rotAbout(p1, p2, a) = pSum(rot(pDiff(p1, p2), a), p2); // rotate p1 about p2

"""

filename = "BezierScad.scad"
require('fs').writeFile "./#{filename}", bezScad

bezTest = """
use <#{filename}>;
x = 25;

""" + (for order in [2...orderMax]
  """

  translate([#{27*(order-2)},0,0]) linear_extrude(height = 5) 
  BezLine( [
    [0,0],
    #{("[#{
      switch 
        when i is order/2 then "x/2"
        when i < order/2 then "0"
        else "x"
     }, #{
      switch 
        when i is order/2 then "5"
        else "x"
     }]" for i in [1...order]).join(", ")},
    [x,0],
  ] , [1.5], #{2+Math.round(order/3)} );
  """
).join('\n') + """


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


"""

require('fs').writeFile "./BezierTest.scad", bezTest


###
bezScad +=  """
function BezArr(p, resolution = 4) = 
  
""" + (
  for order in [1..orderMax]
    """
    len(p) == #{order} ? BezArr#{order}(p, resolution) :
    """
).join(' \n  ') + '\n  [];\n\n'

for order in [1..orderMax]
  ps = ("p[#{i}]" for i in [0...order]).join ', '
  bezScad += """

  function BezArr#{order}(p, resolution) = 
    
  """ + (
    for res in [2..maxLineResolution]
      steps = Math.pow(2, res)
      arr = ("BezI#{order}(#{i}/#{(steps-1)}, #{ps})" for i in [0...steps])
      """
      resolution == #{res} ? [#{arr.join ', '}] :
      """
  ).join(' \n  ') + '\n  [];\n'
###

