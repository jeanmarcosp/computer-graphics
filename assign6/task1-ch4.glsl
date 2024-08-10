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

color ray_color(ray r) {
    vec3 unit_direction = normalize(r.direction);
    float a = 0.5 * (unit_direction.y + 1.0);

    color white = color(vec3(1.0, 1.0, 1.0));
    color blue = color(vec3(0.5, 0.7, 1.0));

    return color(vec3((1.0 - a) * white.rgb + a * blue.rgb));
}

void main() {
    float aspect = iResolution.x / iResolution.y;
    
    float viewport_height = 2.0;
    float viewport_width = viewport_height * aspect;

    camera cam;
    cam.origin = vec3(0.0, 0.0, 0.0);
    cam.lower_left_corner = cam.origin - vec3(viewport_width / 2.0, viewport_height / 2.0, 1.0);
    cam.horizontal = vec3(viewport_width, 0.0, 0.0);
    cam.vertical = vec3(0.0, viewport_height, 0.0);
    
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec3 pixel_center = cam.lower_left_corner + uv.x * cam.horizontal + uv.y * cam.vertical;
    vec3 ray_direction = pixel_center - cam.origin;
    ray r = ray(cam.origin, ray_direction);
    color pixel_color = ray_color(r);
    
    gl_FragColor = vec4(pixel_color.rgb, 1.0);
}
