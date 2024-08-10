#include "common.glsl"

#define INFINITY 1.0e30
#define DIFFUSE 1
#define METAL 2
#define DIELECTRIC 3

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

struct material {
    vec3 color_rgb;
    int material_type;
    float variable;
};

struct hit_record {
    vec3 p;
    vec3 normal;
    float t;
    bool front_face;
};

void set_face_normal(inout hit_record rec, const ray r, const vec3 outward_normal) {
    rec.front_face = dot(r.direction, outward_normal) < 0.0;
    rec.normal = outward_normal;
}

struct Sphere {
    vec3 center;
    float radius;
    material mat;
};

bool hit(const Sphere sphere, const ray r, float ray_tmin, float ray_tmax, inout hit_record rec) {

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

float schlick(float cosine, float refractive_index) {
    float r0 = (1.0 - refractive_index) / (1.0 + refractive_index);
    r0 = pow(r0, 2.0);
    return r0 + (1.0 - r0) * pow(1.0 - cosine, 5.0);
}

vec3 material_scatter(const material mat, const vec3 ray_direction, const vec3 hit_normal, inout vec3 attenuation) {

    vec3 scattered_direction;

    if (mat.material_type != DIELECTRIC){
        attenuation *= mat.color_rgb; 
    }

    if (mat.material_type == DIFFUSE) {
        scattered_direction = hit_normal + random_in_unit_sphere(g_seed);

    } else if (mat.material_type == METAL) {
        scattered_direction = reflect(ray_direction, hit_normal) + mat.variable * random_in_unit_sphere(g_seed);

    } else if(mat.material_type == DIELECTRIC){

        vec3 outgoing_normal;
        float ior;
        float cosine;

        if (dot(ray_direction, hit_normal) > 0.0) {
            outgoing_normal = -hit_normal;
            ior = mat.variable;
            cosine = dot(ray_direction, hit_normal);
        } else {
            outgoing_normal = hit_normal;
            ior = 1.0 / mat.variable;
            cosine = -1.0 * dot(ray_direction, hit_normal);
        } 

        vec3 refracted_direction;
        float reflect_prob;

        refracted_direction = refract(ray_direction, outgoing_normal, ior);

        if (length(refracted_direction) > 0.0) {

            reflect_prob = schlick(cosine, ior);

        } else {

            reflect_prob = 1.0;

        }

        if (rand1(g_seed) < reflect_prob) {
            scattered_direction = reflect(normalize(ray_direction), hit_normal);
        } else {
            scattered_direction = refracted_direction;
        }
    }


    return normalize(scattered_direction);
}

color ray_color(const ray r, const Sphere spheres[5]) {
    
    ray r_temp = r;
    vec3 attenuation = vec3(1.0, 1.0, 1.0);

    for(int i = 0; i < MAX_RECURSION; i++) {

        float closest_t = INFINITY;
        vec3 closest_normal;
        vec3 closest_intersection;
        bool hit_anything = false;
        vec3 new_dir;
        int closest_idx = 0;

        for (int j = 0; j < 5; ++j) {

            hit_record rec;

            if (hit(spheres[j], r_temp, 0.00001, closest_t, rec)) {

                hit_anything = true;
                closest_t = rec.t;
                closest_normal = rec.normal;
                closest_intersection = rec.p;
                closest_idx = j;
            }
        }

        if(hit_anything){
            new_dir = material_scatter(spheres[closest_idx].mat, r_temp.direction, closest_normal, attenuation);
            r_temp = ray(closest_intersection, normalize(new_dir));
        }

        if (!hit_anything) {
            vec3 unit_direction = normalize(r_temp.direction);
            float a = 0.5 * (unit_direction.y + 1.0);

            color white = color(vec3(1.0, 1.0, 1.0));
            color blue = color(vec3(0.5, 0.7, 1.0));

            return color(attenuation.rgb * (vec3((1.0 - a) * white.rgb + a * blue.rgb)));
        }
    }

    return color(attenuation);
} 


void main() {
    
    float aspect = iResolution.x / iResolution.y;

    float vfov = 30.0; 

    float defocus_angle = 20.0; 
    float focus_dist = sqrt(27.0);

    vec3 lookfrom = vec3(3.0, 3.0, 2.0); 
    vec3 lookat = (vec3(0.0, 0.0, -1.0)); 
    vec3 vup = vec3(0.0, 1.0, 0.0); 

    vec3 w = normalize(lookfrom - lookat); 
    vec3 u = normalize(cross(vup, w)); 
    vec3 v = cross(w, u); 

    float theta = radians(vfov); 
    float h = tan(theta / 2.0); 
    float viewport_height = 2.0 * h * focus_dist; 
    float viewport_width = viewport_height * aspect; 

    vec3 viewport_u = viewport_width * u; 
    vec3 viewport_v = viewport_height * v; 

    vec3 pixel_delta_u = viewport_u / aspect; 
    vec3 pixel_delta_v = viewport_v / aspect; 

    vec3 viewport_lower_left = lookfrom - (focus_dist * w) - (viewport_u / 2.0) - (viewport_v / 2.0);  // good

    float defocus_radius = focus_dist * tan(radians(defocus_angle / 2.0));
    vec3 defocus_disk_u = u * defocus_radius;
    vec3 defocus_disk_v = v * defocus_radius;

    camera cam;
    cam.origin = lookfrom;
    cam.lower_left_corner = viewport_lower_left;
    cam.horizontal = viewport_u;
    cam.vertical = viewport_v;

    material s0 = material(vec3(0.8, 0.8, 0.0), 1, 0.0); //ground sphere
    material s1 = material(vec3(0.1, 0.2, 0.5), 1, 0.0); //center sphere
    material s2 = material(vec3(0.98, 0.96, 0.96), 3, 1.5); //left sphere
    material s3 = material(vec3(0.8, 0.6, 0.2), 2, 0.0); //right sphere

    Sphere spheres[5];
    spheres[0] = Sphere(vec3(0.0, 0.0, -1.0), 0.5, s1); //center sphere
    spheres[1] = Sphere(vec3(-1.0, 0.0, -1.0), 0.5, s2); //left sphere
    spheres[2] = Sphere(vec3(1.0, 0.0, -1.0), 0.5, s3); //right sphere
    spheres[3] = Sphere(vec3(0.0, -100.5, -1.0), 100.0, s0); //ground sphere
    spheres[4] = Sphere(vec3(-1.0, 0.0, -1.0), -0.4, s2); //left sphere 2

    color col = color(vec3(0.0, 0.0, 0.0));
    init_rand(gl_FragCoord.xy, iTime);

    for(int i = 0; i < 100; i++){

        vec2 uv = (gl_FragCoord.xy + rand2(g_seed)) / iResolution.xy ;
        vec2 uvp = vec2(uv.x * viewport_width, uv.y * viewport_height);

        uvp += vec2(-viewport_width * 0.5, -viewport_height * 0.5);

        vec3 world = vec3(uvp.x, uvp.y, -focus_dist);

        vec2 rd = defocus_radius * random_in_unit_disk(g_seed);
        vec3 offset = rd.x * u + rd.y * v;

        vec3 ray_origin = cam.origin + offset;
        vec3 ray_direction = normalize(cam.lower_left_corner + (uv.x * cam.horizontal) + (uv.y * cam.vertical) - ray_origin);

        ray r = ray(ray_origin, ray_direction);
        col.rgb += ray_color(r, spheres).rgb;
    }

    vec3 colAverage = col.rgb/(100.0);

    colAverage = pow(colAverage, vec3(1.0/2.2));

    gl_FragColor = vec4(colAverage, 1.0);
}