#define SPHERE 0
#define BOX 1
#define CYLINDER 3
#define CONE 5
#define NONE 4

////////////////////////////////////////////////////
// TASK 1 - Write up your SDF code here:
////////////////////////////////////////////////////

// returns the signed distance to a sphere from position p
float sdSphere(vec3 p, float r)
{
    return length(p) - r;
}

// Task 1.1
//
// Returns the signed distance to a line segment.
//
// p is the position you are evaluating the distance to.
// a and b are the end points of your line.
//
float sdLine(in vec2 p, in vec2 a, in vec2 b)
{

// ################ Edit your code below ################

    vec2 ab = b - a;
    vec2 pa = p - a;

    float t = dot(pa, ab) / dot(ab, ab);

    t = clamp(t, 0.0, 1.0);

    return length(p - (a + t * ab));
}

// Task 1.2
//
// Returns the signed distance from position p to an axis-aligned box centered at the origin with half-length,
// half-height, and half-width specified by half_bounds
//
float sdBox(vec3 p, vec3 half_bounds)
{

// ################ Edit your code below ################

    vec3 d = abs(p) - half_bounds;
    
    return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}

// Task 1.3
//
// Returns the signed distance from position p to a cylinder or radius r with an axis connecting the two points a and b.
//
float sdCylinder(vec3 p, vec3 a, vec3 b, float r)
{

// ################ Edit your code below ################

    float dot1 = dot(b - a,b - a);
    float dot2 = dot(p - a,b - a);

    float x = length((p - a) * dot1 - (b - a) * dot2) - (r * dot1);
    float y = abs(dot2 - dot1 * 0.5) - (dot1 * 0.5);

    float x2 = pow(x, 2.0);
    float y2 = pow(y, 2.0);
    
    float d;

    if (max(x, y) < 0.0) 
    {
        d = -min(x2, y2);
    } 
    else 
    {
        float x2_check;
        float y2_check;

        if (x > 0.0) {
            x2_check = x2;
        }
        if (y > 0.0) {
            y2_check = y2;
        }

        d = x2_check + y2_check;
    }    

    return sign(d) * sqrt(abs(d));
}

// Task 1.4
//
// Returns the signed distance from position p to a cone with axis connecting points a and b and (ra, rb) being the
// radii at a and b respectively.
//
float sdCone(vec3 p, vec3 a, vec3 b, float ra, float rb)
{

// ################ Edit your code below ################

    float radius  = rb - ra;

    float length = dot(b - a,b - a);
    float distance = dot(p - a,p - a);
    float projection = dot(p - a,b - a) / length;

    float x = sqrt(distance - pow(projection, 2.0) * length);

    float ax;
    if (projection < 0.5) {
        ax = max(0.0, x - ra);
    } else {
        ax = max(0.0, x - rb);
    }

    float ay = abs(projection - 0.5) - 0.5;

    float inter = clamp((radius * (x - ra) + (projection * length)) / (pow(radius, 2.0) + length), 0.0, 1.0);

    float bx = x - ra - (inter * radius);
    float by = projection - inter;
    
    float resA = pow(ax, 2.0) + pow(ay, 2.0) * length;
    float resB = pow(bx, 2.0) + pow(by, 2.0) * length;

    if (bx < 0.0 && ay < 0.0) {
        return -1.0 * sqrt(min(resA,resB));
    } else {
        return sqrt(min(resA,resB));
    }
}

// Task 1.5
float opSmoothUnion(float d1, float d2, float k)
{

// ################ Edit your code below ################

    float h = max(k - abs(d1 - d2), 0.0);
    return min(d1, d2) - (pow(h, 2.0) / (4.0 * k));
}

// Task 1.6
float opSmoothIntersection(float d1, float d2, float k)
{

// ################ Edit your code below ################

    float h = max(k - abs(d1 - d2), 0.0);
    return max(d1, d2) + (pow(h, 2.0) / (4.0 * k)); 
}

// Task 1.7
float opSmoothSubtraction(float d1, float d2, float k)
{

// ################ Edit your code below ################

    float h = max(k - abs(d1 + d2), 0.0);
    return max(-d1, d2) + (pow(h, 2.0) / (4.0 * k));
}

// Task 1.8
float opRound(float d, float iso)
{

// ################ Edit your code below ################

    return d - iso;
}

////////////////////////////////////////////////////
// FOR TASK 3 & 4
////////////////////////////////////////////////////

#define TASK3 3
#define TASK4 4
#define TASK5 5

// Render Settings
//
struct settings
{
    int sdf_func;      // Which primitive is being visualized (e.g. SPHERE, BOX, etc.)
    int shade_mode;    // How the primiive is being visualized (GRID or COST)
    int marching_type; // Should we use RAY_MARCHING or SPHERE_TRACING?
    int task_world;    // Which task is being rendered (TASK3 or TASK4)?
    float anim_speed;  // Specifies the animation speed
};

// returns the signed distance to an infinite plane with a specific y value
float sdPlane(vec3 p, float z)
{
    return p.y - z;
}

float world_sdf(vec3 p, float time, settings setts)
{
    if (setts.task_world == TASK3)
    {
        if ((setts.sdf_func == SPHERE) || (setts.sdf_func == NONE))
        {
            return min(sdSphere(p - vec3(0.f, 0.25 * cos(setts.anim_speed * time), 0.f), 0.4f), sdPlane(p, 0.f));
        }
        if (setts.sdf_func == BOX)
        {
            return min(sdBox(p - vec3(0.f, 0.25 * cos(setts.anim_speed * time), 0.f), vec3(0.4f)), sdPlane(p, 0.f));
        }
        if (setts.sdf_func == CYLINDER)
        {
            return min(sdCylinder(p - vec3(0.f, 0.25 * cos(setts.anim_speed * time), 0.f), vec3(0.0f, -0.4f, 0.f),
                                  vec3(0.f, 0.4f, 0.f), 0.2f),
                       sdPlane(p, 0.f));
        }
        if (setts.sdf_func == CONE)
        {
            return min(sdCone(p - vec3(0.f, 0.25 * cos(setts.anim_speed * time), 0.f), vec3(-0.4f, 0.0f, 0.f),
                              vec3(0.4f, 0.0f, 0.f), 0.1f, 0.6f),
                       sdPlane(p, 0.f));
        }
    }

    if (setts.task_world == TASK4)
    {
        float dist = 100000.0;

        dist = sdPlane(p.xyz, -0.3);
        dist = opSmoothUnion(dist, sdSphere(p - vec3(0.f, 0.25 * cos(setts.anim_speed * time), 0.f), 0.4f), 0.1);
        dist = opSmoothUnion(
            dist, sdSphere(p - vec3(sin(time), 0.25 * cos(setts.anim_speed * time * 2. + 0.2), cos(time)), 0.2f), 0.01);
        dist = opSmoothSubtraction(sdBox(p - vec3(0.f, 0.25, 0.f), 0.1 * vec3(2. + cos(time))), dist, 0.2);
        dist = opSmoothUnion(
            dist, sdSphere(p - vec3(sin(-time), 0.25 * cos(setts.anim_speed * time * 25. + 0.2), cos(-time)), 0.2f),
            0.1);

        return dist;
    }

    if (setts.task_world == TASK5)
    {
        float dist = 100000.0;

        dist = sdPlane(p.xyz, -0.3);

        vec3 boxPosition0 = vec3(-0.6, 0.2 * abs(sin(time)), 0.0);
        vec3 boxPosition1 = vec3(-0.3, 0.4 * abs(sin(time * 1.5)), 0.0);
        vec3 boxPosition2 = vec3(0.0, 0.2 * abs(sin(time * 2.0)), 0.0);
        vec3 boxPosition3 = vec3(0.3, 0.3 * abs(sin(time * 2.5)), 0.0);
        vec3 boxPosition4 = vec3(0.6, 0.1 * abs(sin(time * 3.0)), 0.0);

        dist = opSmoothUnion(dist, sdBox(p - boxPosition0, vec3(0.1)), 0.1);
        dist = opSmoothUnion(dist, sdBox(p - boxPosition1, vec3(0.1)), 0.1);
        dist = opSmoothUnion(dist, sdBox(p - boxPosition2, vec3(0.1)), 0.1);
        dist = opSmoothUnion(dist, sdBox(p - boxPosition3, vec3(0.1)), 0.1);
        dist = opSmoothUnion(dist, sdBox(p - boxPosition4, vec3(0.1)), 0.1);

        vec3 spherePosition0 = vec3(cos(-time), sin(-time), 0.0);
        vec3 spherePosition1 = vec3(cos(-time + 1.0), sin(-time + 1.0), 0.0);
        vec3 spherePosition2 = vec3(cos(-time + 2.0), sin(-time + 2.0), 0.0);
        vec3 spherePosition3 = vec3(cos(-time + 3.0), sin(-time + 3.0), 0.0);
        vec3 spherePosition4 = vec3(cos(-time + 4.0), sin(-time + 4.0), 0.0);
        vec3 spherePosition5 = vec3(cos(-time + 5.0), sin(-time + 5.0), 0.0);


        dist = opSmoothUnion(dist, sdSphere(p - spherePosition0, 0.1), 0.1);
        dist = opSmoothUnion(dist, sdSphere(p - spherePosition1, 0.1), 0.1);
        dist = opSmoothUnion(dist, sdSphere(p - spherePosition2, 0.1), 0.1);
        dist = opSmoothUnion(dist, sdSphere(p - spherePosition3, 0.1), 0.1);
        dist = opSmoothUnion(dist, sdSphere(p - spherePosition4, 0.1), 0.1);
        dist = opSmoothUnion(dist, sdSphere(p - spherePosition5, 0.1), 0.1);


        return dist;
    }



    return 1.f;
}