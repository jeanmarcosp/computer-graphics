#include "sdf.glsl"
#include "common.glsl"

////////////////////////////////////////////////////
// TASK 2 - Write up your ray generation code here:
////////////////////////////////////////////////////
//
// Ray
//
struct ray
{
    vec3 origin;    // This is the origin of the ray
    vec3 direction; // This is the direction the ray is pointing in
};

// TASK 2.1
void compute_camera_frame(vec3 dir, vec3 up, out vec3 u, out vec3 v, out vec3 w)
{

// ################ Edit your code below ################
    w = normalize(-dir);    
    u = normalize(cross(up, w)); 
    v = normalize(cross(w, u)); 
    
}

// TASK 2.2
ray generate_ray_orthographic(vec2 uv, vec3 e, vec3 u, vec3 v, vec3 w)
{

// ################ Edit your code below ################

    vec3 origin = e + uv.x * u + uv.y * v;
    vec3 direction = -w;
    
    return ray(origin, direction);
}

// TASK 2.3
ray generate_ray_perspective(vec2 uv, vec3 eye, vec3 u, vec3 v, vec3 w, float focal_length)
{

// ################ Edit your code below ################

    vec3 direction = normalize(-focal_length * w + uv.x * u + uv.y * v);
    vec3 origin = eye;

    return ray(origin, direction);
}

////////////////////////////////////////////////////
// TASK 3 - Write up your code here:
////////////////////////////////////////////////////

// TASK 3.1
bool ray_march(ray r, float step_size, int max_iter, settings setts, out vec3 hit_loc, out int iters)
{

// ################ Edit your code below ################

    // hit_loc = r.origin + r.direction * (-r.origin.y / r.direction.y);
    // iters = 1;
    // return true;

    // TODO: implement ray marching

    // it should work as follows:
    //
    // while (hit has not occured && iteration < max_iters)
    //     march a distance of step_size forwards
    //     evaluate the sdf
    //     if a collision occurs (SDF < EPSILON)
    //         return hit location and iteration count
    // return false

    iters = 1;
    vec3 current_pos = r.origin;

    while (iters < max_iter){

        current_pos += step_size * r.direction;

        float SDF = world_sdf(current_pos, iTime, setts); 

        if (SDF < EPSILON)
        {
            hit_loc = current_pos;
            return true; 
        }

        iters++;
    }

    iters = max_iter;
    return false;
}

// TASK 3.2
bool sphere_tracing(ray r, int max_iter, settings setts, out vec3 hit_loc, out int iters)
{

// ################ Edit your code below ################

    // hit_loc = r.origin + r.direction * (-r.origin.y / r.direction.y);
    // iters = 1;
    // return true;

    // TODO: implement sphere tracing

    // it should work as follows:
    //
    // while (hit has not occured && iteration < max_iters)
    //     set the step size to be the SDF
    //     march step size forwards
    //     if a collision occurs (SDF < EPSILON)
    //         return hit location and iteration count
    // return false

    iters = 1;
    vec3 current_pos = r.origin;

    while (iters < max_iter){

        float SDF = world_sdf(current_pos, iTime, setts); 

        current_pos += SDF * r.direction;

        if (SDF < EPSILON)
        {
            hit_loc = current_pos;
            return true; 
        }

        iters++;
    }

    iters = max_iter;
    return false;
}

////////////////////////////////////////////////////
// TASK 4 - Write up your code here:
////////////////////////////////////////////////////

float map(vec3 p, settings setts)
{
    return world_sdf(p, iTime, setts);
}

// TASK 4.1
vec3 computeNormal(vec3 p, settings setts)
{

// ################ Edit your code below ################

    vec3 v1 = vec3(EPSILON, 0.0, 0.0);
    vec3 v2 = vec3(0.0, EPSILON, 0.0);
    vec3 v3 = vec3(0.0, 0.0, EPSILON);

    vec3 normal = vec3(
        world_sdf(p + v1, iTime, setts) - world_sdf(p - v1, iTime, setts),
        world_sdf(p + v2, iTime, setts) - world_sdf(p - v2, iTime, setts),
        world_sdf(p + v3, iTime, setts) - world_sdf(p - v3, iTime, setts)
    );

    return normalize(normal);
}
