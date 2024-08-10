var WireframeMesh = function(vertexPositions, indices)
{
    this.positions = vertexPositions;
    this.indices = indices;
}

WireframeMesh.prototype.vertex = function(index)
{
    return [this.positions[3*index], this.positions[3*index+1], this.positions[3*index+2]];
}

WireframeMesh.prototype.render = function(canvas)
{
    var context = canvas.getContext('2d');
    context.beginPath();

    for (var i = 0; i < this.indices.length; i+=2)
    {
        var index1 = this.indices[i];
        var index2 = this.indices[i+1];

        var xyz1 = this.vertex(index1);
        var xyz2 = this.vertex(index2);

        // TODO: Implement a simple perspective projection by dividing the x and
        //       y components by the z component.
        //
        // Extract the components using
        //      xyz1[0]    (x-component)
        //      xyz1[1]    (y-component)
        //      xyz1[2]    (z-component)
        //
        // Do the perspective division
        //
        //      var projectedX = .....
        //      var projectedY = .....
        //
        // Assemble projected points
        //
        // var xy1 = [projectedX, projectedY];
        
        // Do the same thing for xyz2 and compute an equivalent
        //
        // var xy2 = [......];
        // 
        

// ################ Edit your code below
        // Orthographic projection, to get you started
        var projectedX1 = xyz1[0] / xyz1[2]
        var projectedY1 = xyz1[1] / xyz1[2]

        var xy1 = [projectedX1, projectedY1];

        var projectedX2 = xyz2[0] / xyz2[2]
        var projectedY2 = xyz2[1] / xyz2[2]

        var xy2 = [projectedX2, projectedY2];
// ################


        // projected points scaled and centered within the canvas
        var aspect = canvas.width/canvas.height;
        var uv1 = [(xy1[0] + 0.5)*canvas.width, (xy1[1] + 0.5 / aspect)*canvas.width];
        var uv2 = [(xy2[0] + 0.5)*canvas.width, (xy2[1] + 0.5 / aspect)*canvas.width];

        // draw the line segment
        context.moveTo(uv1[0], uv1[1]);
        context.lineTo(uv2[0], uv2[1]);
    }

    context.stroke();
}

var Task1 = function(canvas) {
    this.mesh1 = new WireframeMesh(Task1_WireCubePositionsOne, WireCubeIndices);
    this.mesh2 = new WireframeMesh(Task1_WireCubePositionsTwo, WireCubeIndices);
    this.mesh3 = new WireframeMesh(Task1_SpherePositions, SphereIndices);
}

Task1.prototype.render = function(canvas, gl, w, h) {
    var context = canvas.getContext('2d');
    clear(context, w, h);
    
    this.mesh1.render(canvas);
    this.mesh2.render(canvas);
    this.mesh3.render(canvas);
}

Task1.prototype.dragCamera = function(dy) {}
