#define INFINITY 1.0e30

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

////////////////////////////////////////////// 
//                  TASK 3                  //
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

bool hit(const Sphere sphere, const ray r, float ray_tmin, float ray_tmax, out hit_record rec) {

    vec3 oc = r.origin - sphere.center;
    float a = dot(r.direction, r.direction);
    float half_b = dot(oc, r.direction);
    float c = dot(oc, oc) - sphere.radius * sphere.radius;

    float discriminant = half_b * half_b - a * c;

    if (discriminant < 0.0){
        return false;
    } 

    float sqrtd = sqrt(discriminant);
    float root = (-half_b - sqrtd) / a;
    
    if (root <= ray_tmin || ray_tmax <= root) {
        root = (-half_b + sqrtd) / a;
        if (root <= ray_tmin || ray_tmax <= root)
            return false;
    }

    rec.t = root;
    rec.p = r.origin + rec.t * r.direction;

    vec3 outward_normal = (rec.p - sphere.center) / sphere.radius;
    set_face_normal(rec, r, outward_normal);
    
    return true;
}

// float hit_sphere(vec3 center, float radius, ray r) {

//     ////////////////////////////////////////////// 
//     //                  TASK 3                  //
//     vec3 oc = r.origin - center;
//     float a = dot(r.direction, r.direction);
//     float half_b = dot(oc, r.direction);
//     float c = dot(oc, oc) - radius * radius;
//     float discriminant = half_b * half_b - a * c;

//     if (discriminant < 0.0) {
//         return -1.0;
//     } else {
//         return ( -half_b - sqrt(discriminant) ) / a;
//     }
//     ////////////////////////////////////////////// 
// }

color ray_color(const ray r, const Sphere spheres[2]) {

    hit_record rec;
    float max = INFINITY;

    for (int i = 0; i < 2; ++i) {
        if (hit(spheres[i], r, 0.0, max, rec)) {
            color c = color(vec3(1.0,1.0,1.0));
            return color(0.5 * (rec.normal + c.rgb));
        }
    }

    vec3 unit_direction = normalize(r.direction);
    float a = 0.5 * (unit_direction.y + 1.0);

    color white = color(vec3(1.0, 1.0, 1.0));
    color blue = color(vec3(0.5, 0.7, 1.0));

    return color(vec3((1.0 - a) * white.rgb + a * blue.rgb));
}
////////////////////////////////////////////// 


void main() {
    float aspect = iResolution.x / iResolution.y;
    
    float viewport_height = 2.0;
    float viewport_width = viewport_height * aspect;

    camera cam;
    cam.origin = vec3(0.0, 0.0, 0.0);
    cam.lower_left_corner = cam.origin - vec3(viewport_width / 2.0, viewport_height / 2.0, 1.0);
    cam.horizontal = vec3(viewport_width, 0.0, 0.0);
    cam.vertical = vec3(0.0, viewport_height, 0.0);

    ////////////////////////////////////////////// 
    //                  TASK 3                  //
    Sphere spheres[2];
    spheres[0] = Sphere(vec3(0.0, 0.0, -1.0), 0.5);
    spheres[1] = Sphere(vec3(0.0, -100.5, -1.0), 100.0);
    ////////////////////////////////////////////// 

    
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec3 pixel_center = cam.lower_left_corner + uv.x * cam.horizontal + uv.y * cam.vertical;
    vec3 ray_direction = pixel_center - cam.origin;

    ray r = ray(cam.origin, ray_direction);
    color pixel_color = ray_color(r, spheres);
    
    gl_FragColor = vec4(pixel_color.rgb, 1.0);
}
