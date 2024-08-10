#define INFINITY 1.0e30
#include "common.glsl"

// Color struct
struct color {
    vec3 rgb;
};

// Ray struct
struct ray {
    vec3 origin;
    vec3 direction;
};

// Camera struct
struct camera {
    vec3 origin;
    vec3 lower_left_corner;
    vec3 horizontal;
    vec3 vertical;
};

struct hit_record {
    vec3 p;
    vec3 normal;
    float t;
    bool front_face;
};

void set_face_normal(inout hit_record rec, const ray r, const vec3 outward_normal) {
    rec.front_face = dot(r.direction, outward_normal) < 0.0;
    rec.normal = rec.front_face ? outward_normal : -outward_normal;
}

struct Sphere {
    vec3 center;
    float radius;
};

// bool hit(const Sphere sphere, const ray r, float ray_tmin, float ray_tmax, out hit_record rec) {

//     vec3 oc = r.origin - sphere.center;
//     float a = dot(r.direction, r.direction);
//     float half_b = dot(oc, r.direction);
//     float c = dot(oc, oc) - sphere.radius * sphere.radius;

//     float discriminant = half_b * half_b - a * c;

//     if (discriminant < 0.0){
//         return false;
//     } 

//     float sqrtd = sqrt(discriminant);
//     float root = (-half_b - sqrtd) / a;
    
//     if (root <= ray_tmin || ray_tmax <= root) {
//         root = (-half_b + sqrtd) / a;
//         if (root <= ray_tmin || ray_tmax <= root)
//             return false;
//     }

//     rec.t = root;
//     rec.p = r.origin + rec.t * r.direction;

//     vec3 outward_normal = (rec.p - sphere.center) / sphere.radius;
//     set_face_normal(rec, r, outward_normal);
    
//     return true;
// }

float hit_sphere(vec3 center, float radius, ray r) {

    vec3 oc = r.origin - center;
    float a = dot(r.direction, r.direction);
    float half_b = dot(oc, r.direction);
    float c = dot(oc, oc) - radius * radius;
    float discriminant = half_b * half_b - a * c;

    if (discriminant < 0.0) {
        return -1.0;
    } else {
        return ( -half_b - sqrt(discriminant) ) / a;
    }
    
}

color ray_color(const ray r, const Sphere spheres[2]) {

    ray r_temp = r;
    vec3 diffuse_color = vec3(1.0, 1.0, 1.0);

    for(int i = 0; i < 100; i++){
        // part 1: generating new ray
        
        float t = hit_sphere(spheres[0].center, spheres[0].radius, r_temp);
        float t2 = hit_sphere(spheres[1].center, spheres[1].radius, r_temp);

        vec3 unit_direction = normalize(r_temp.direction);

        //position = ray's origin + t in direction of ray
        vec3 p = r_temp.origin + unit_direction * t;
        vec3 n = normalize(p - spheres[0].center);

        vec3 p2 = r_temp.origin + unit_direction * t2;
        vec3 n2 = normalize(p2 - spheres[1].center);

        //if ray intersects anything in scene
        if(t > 0.0|| t2 > 0.0){

            vec3 pIntersection;

            if (t < t2 && t > 0.0 || t2 < 0.0){
                //p is intersection point
                pIntersection = p;
            }else{
                //p2 is intersection point
               pIntersection = p2;
            }

            vec3 nIntersection;
            nIntersection = n;
            
            if (t < t2 && t > 0.0|| t2 < 0.0){
                //n is intersection point
                nIntersection = n;
            }else{
                //n2 is intersection point
                nIntersection = n2;
            }

            vec3 new_dir = nIntersection + random_in_unit_sphere(g_seed);
            ray new_ray = ray(pIntersection, normalize(new_dir));
            r_temp = new_ray;
            diffuse_color *= 0.5;
        }
        else {
            float a = 0.5 * (unit_direction.y + 1.0);

            color white = color(vec3(1.0, 1.0, 1.0));
            color blue = color(vec3(0.5, 0.7, 1.0));

            return color(diffuse_color.rgb * vec3((1.0 - a) * white.rgb + a * blue.rgb));
        }
    }
    return color(diffuse_color);
} 


void main() {
    float aspect = iResolution.x / iResolution.y;
    
    float viewport_height = 2.0;
    float viewport_width = viewport_height * aspect;
    float focal_length = 1.0;

    camera cam;
    cam.origin = vec3(0.0, 0.0, 0.0);
    cam.lower_left_corner = cam.origin - vec3(viewport_width / 2.0, viewport_height / 2.0, 1.0);
    cam.horizontal = vec3(viewport_width, 0.0, 0.0);
    cam.vertical = vec3(0.0, viewport_height, 0.0);

    Sphere spheres[2];
    spheres[0] = Sphere(vec3(0.0, 0.0, -1.0), 0.5);
    spheres[1] = Sphere(vec3(0.0, -100.5, -1.0), 100.0);

    color col = color(vec3(0.0, 0.0, 0.0));
    init_rand(gl_FragCoord.xy, iTime);

    for(int i = 0; i < 100; i++){

        vec2 uv = (gl_FragCoord.xy + rand2(g_seed)) / iResolution.xy ;
        vec2 uvp = vec2(uv.x * viewport_width, uv.y * viewport_height);

        uvp += vec2(-viewport_width * 0.5, -viewport_height * 0.5);

        vec3 world = vec3(uvp.x, uvp.y, -focal_length);
        vec3 ray_direction = normalize(world - cam.origin);

        ray r = ray(cam.origin, ray_direction);
        col.rgb += ray_color(r, spheres).rgb;
    }

    vec3 colAverage = col.rgb/(100.0);

    colAverage = pow(colAverage, vec3(1.0/2.2));
    
    if(colAverage.r == 1.0){
        gl_FragColor.r = 1.0;
    }
    else{
        gl_FragColor.r  = 0.0;
    }

    if(colAverage.g == 1.0){
        gl_FragColor.g = 1.0;
    }
    else{
        gl_FragColor.g  = 0.0;
    }

    if(colAverage.b == 1.0){
        gl_FragColor.b = 1.0;
    }
    else{
        gl_FragColor.b  = 0.0;
    }

    gl_FragColor = vec4(colAverage, 1.0);
}
