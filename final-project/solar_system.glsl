#iChannel0 "file://textures/2k_earth_daymap.jpg"
#iChannel1 "file://textures/2k_mars.jpg"
#iChannel2 "file://textures/stars2.jpeg"
#iChannel3 "file://textures/2k_mercury.jpg"
#iChannel4 "file://textures/2k_venus_surface.jpg"
#iChannel5 "file://textures/2k_jupiter.jpg"
#iChannel6 "file://textures/2k_saturn.jpg"
#iChannel7 "file://textures/2k_uranus.jpg"
#iChannel8 "file://textures/2k_neptune.jpg"
#iChannel9 "file://textures/2k_sun.jpg"

//spheres adapted from: https://www.shadertoy.com/view/flyGWW
//orbital rings adapted from: https://www.shadertoy.com/view/XtXBRX
//textures found here: https://www.solarsystemscope.com/textures/

//code for pluto commented out for aesthetic reasons

#define PI 3.141592653
#define dist 0.00062

vec3 createOrbit(float m, vec2 uv) 
{ 
    vec3 colorOrbit = vec3(0.18, 0.17, 0.17);
    return mix(vec3(0.0), colorOrbit, smoothstep(1.5/iResolution.y, 0.0, abs(length(uv)-(m)))); 
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float aspect = iResolution.x / iResolution.y;
    vec2 uv = gl_FragCoord.xy / iResolution.xy - 0.5;
    uv.x *= aspect;

    vec3 cam_origin = vec3(10.0, 0.0, 0.0);
    vec3 cam_target = vec3(0.0, 0.0, 0.0);
    vec3 cam_up = vec3(0.0, 1.0, 0.0);
    
    vec3 eye = vec3(140.0, 0.0, 1.0);
    vec3 dir = vec3(0.0, 0.0, 0.0) - eye;
    vec3 up = vec3(0, 1, 0);

    vec3 w = normalize(cam_origin + cam_target);
    vec3 u = normalize(cross(cam_up, w));
    vec3 v = cross(w, u);

    vec4 backgroundImage = texture(iChannel2,uv*2.5);
    fragColor += backgroundImage/1.5;

    vec3 col = vec3(0.0); 

    vec3 orbitMercury = createOrbit(dist*138.0, uv);
    vec3 orbitVenus = createOrbit(dist*173.0, uv);
    vec3 orbitEarth = createOrbit(dist*208.0, uv);
    vec3 orbitMars = createOrbit(dist*242.0, uv);
    vec3 orbitJupiter = createOrbit(dist*333.0, uv);
    vec3 orbitSaturn = createOrbit(dist*483.0, uv);
    vec3 orbitUranus = createOrbit(dist*612.0, uv);
    vec3 orbitNeptune = createOrbit(dist*738.0, uv);
    // vec3 orbitPluto = createOrbit(dist*726.0, uv);
    
    col += orbitMercury;
    col += orbitVenus;
    col += orbitEarth;
    col += orbitMars;
    col += orbitJupiter;
    col += orbitSaturn;
    col += orbitUranus;
    col += orbitNeptune;
    // col += orbitPluto;

    const vec3 orbitCenter = vec3(0.0, 0.0, 0.0); 
    
    vec3 ray_origin = eye + normalize(cross(dir, up));
    vec3 ray_direction = normalize(u * uv.x + v * uv.y - w);

    float ll = 0.0;

    // Earth
    for(int i = 0; i < 100; i++)
    {
        float orbitRadius = 18.0;                
        float orbitSpeed = 1.0;  
        float orbitAngle = iTime * orbitSpeed;
        vec3 orbitPosition = orbitCenter + vec3(0.0, sin(iTime * orbitSpeed) * orbitRadius, cos(iTime * orbitSpeed) * orbitRadius);
        
        vec3 p = ray_origin + ray_direction * ll - orbitPosition;
        float dd = length(p) - 1.0;
    
        if(dd < 0.001)
        {
            p.xz *= mat2(cos(-iTime), -sin(-iTime), sin(-iTime), cos(-iTime)); 
            float a = 0.5 + atan(p.x, p.z) / (2.0 * PI);
            float b = 0.5 - asin(p.y / length(p)) / PI;
            vec3 diff = texture(iChannel0, vec2(-a, -b)).rgb;
            col = diff;
            break;
        }

        ll += dd;

    }
    
    // Mars
    ll = 0.0;
    
    for(int i = 0; i < 100; i++)
    {
        float orbitRadius = 21.0;                
        float orbitSpeed = 0.8;  
        float orbitAngle = iTime * orbitSpeed;
        vec3 orbitPosition = orbitCenter + vec3(0.0, sin(iTime * orbitSpeed) * orbitRadius, cos(iTime * orbitSpeed) * orbitRadius);
        
        vec3 p = ray_origin + ray_direction * ll - orbitPosition;
        float dd = length(p) - 0.53;
        
        if(dd < 0.001)
        {
            p.xz *= mat2(cos(-iTime * 0.55), -sin(-iTime * 0.55), sin(-iTime * 0.55), cos(-iTime * 0.55)); 
            float a = 0.5 + atan(p.x, p.z) / (2.0 * PI);
            float b = 0.5 - asin(p.y / length(p)) / PI;
            vec3 diff = texture(iChannel1, vec2(-a, -b)).rgb;
            col = diff; 
            break;
        }
        
        ll += dd;
    }

    // Mercury
    ll = 0.0;
    
    for(int i = 0; i < 100; i++)
    {
        float orbitRadius = 12.0;               
        float orbitSpeed = 1.6;  
        float orbitAngle = iTime * orbitSpeed;
        vec3 orbitPosition = orbitCenter + vec3(0.0, sin(iTime * orbitSpeed) * orbitRadius, cos(iTime * orbitSpeed) * orbitRadius);
        
        vec3 p = ray_origin + ray_direction * ll - orbitPosition;
        float dd = length(p) - 0.38;
        
        if(dd < 0.001)
        {
            p.xz *= mat2(cos(-iTime * 0.006), -sin(-iTime * 0.006), sin(-iTime * 0.006), cos(-iTime * 0.006)); 
            float a = 0.5 + atan(p.x, p.z) / (2.0 * PI);
            float b = 0.5 - asin(p.y / length(p)) / PI;
            vec3 diff = texture(iChannel3, vec2(-a, -b)).rgb;
            col = diff; 
            break;
        }
        
        ll += dd;
    }

    // Venus
    ll = 0.0;
    
    for(int i = 0; i < 100; i++)
    {
        float orbitRadius = 15.0;                
        float orbitSpeed = 1.17;  
        float orbitAngle = iTime * orbitSpeed;
        vec3 orbitPosition = orbitCenter + vec3(0.0, sin(iTime * orbitSpeed) * orbitRadius, cos(iTime * orbitSpeed) * orbitRadius);
        
        vec3 p = ray_origin + ray_direction * ll - orbitPosition;
        float dd = length(p) - 0.95;
        
        if(dd < 0.001)
        {
            p.xz *= mat2(cos(-iTime * 0.004), -sin(-iTime * 0.004), sin(-iTime * 0.004), cos(-iTime * 0.004)); 
            float a = 0.5 + atan(p.x, p.z) / (2.0 * PI);
            float b = 0.5 - asin(p.y / length(p)) / PI;
            vec3 diff = texture(iChannel4, vec2(-a, -b)).rgb;
            col = diff; 
            break;
        }
        
        ll += dd;
    }

    // Jupiter
    ll = 0.0;
    
    for(int i = 0; i < 100; i++)
    {
        float orbitRadius = 28.5;                
        float orbitSpeed = 0.44;  
        float orbitAngle = iTime * orbitSpeed;
        vec3 orbitPosition = orbitCenter + vec3(0.0, sin(iTime * orbitSpeed) * orbitRadius, cos(iTime * orbitSpeed) * orbitRadius);
        
        vec3 p = ray_origin + ray_direction * ll - orbitPosition;
        float dd = length(p) - 5.0;
        
        if(dd < 0.001)
        {
            p.xz *= mat2(cos(-iTime * 5.0), -sin(-iTime * 5.0), sin(-iTime * 5.0), cos(-iTime * 5.0)); 
            float a = 0.5 + atan(p.x, p.z) / (2.0 * PI);
            float b = 0.5 - asin(p.y / length(p)) / PI;
            vec3 diff = texture(iChannel5, vec2(-a, -b)).rgb;
            col = diff; 
            break;
        }
        
        ll += dd;
    }

    // Saturn
    ll = 0.0;
    
    for(int i = 0; i < 100; i++)
    {
        float orbitRadius = 41.5;              
        float orbitSpeed = 0.32;  
        float orbitAngle = iTime * orbitSpeed;
        vec3 orbitPosition = orbitCenter + vec3(0.0, sin(iTime * orbitSpeed) * orbitRadius, cos(iTime * orbitSpeed) * orbitRadius);
        
        vec3 p = ray_origin + ray_direction * ll - orbitPosition;
        float dd = length(p) - 4.0;
        
        if(dd < 0.001)
        {
            p.xz *= mat2(cos(-iTime * 4.0), -sin(-iTime * 4.0), sin(-iTime * 4.0), cos(-iTime * 4.0)); 
            float a = 0.5 + atan(p.x, p.z) / (2.0 * PI);
            float b = 0.5 - asin(p.y / length(p)) / PI;
            vec3 diff = texture(iChannel6, vec2(-a, -b)).rgb;
            col = diff; 
            break;
        }

        ll += dd;
    }    

    // Ring 1
    ll = 0.0;
    
    for(int i = 0; i < 100; i++)
    {
        float orbitRadius = 41.5;              
        float orbitSpeed = 0.32;  
        float orbitAngle = iTime * orbitSpeed;
        vec3 orbitPosition = orbitCenter + vec3(0.0, sin(iTime * orbitSpeed) * orbitRadius, cos(iTime * orbitSpeed) * orbitRadius);
        
        vec3 p = ray_origin + ray_direction * ll - orbitPosition;
        float dd = length(vec2(length(p.xz) - 4.90, p.y)) - 0.2;
        
        if(dd < 0.001)
        {   
            float a = 0.5 + atan(p.x, p.z) / (2.0 * PI);
            float b = 0.5 - asin(p.y / length(p)) / PI;
            vec3 diff = texture(iChannel6, vec2(-a, -b)).rgb;
            col = diff; 
            break;
        }
        
        ll += dd;
    }    

    // Ring 2
    ll = 0.0;
    
    for(int i = 0; i < 100; i++)
    {
        float orbitRadius = 41.5;              
        float orbitSpeed = 0.32;  
        float orbitAngle = iTime * orbitSpeed;
        vec3 orbitPosition = orbitCenter + vec3(0.0, sin(iTime * orbitSpeed) * orbitRadius, cos(iTime * orbitSpeed) * orbitRadius);
        
        vec3 p = ray_origin + ray_direction * ll - orbitPosition;
        float dd = length(vec2(length(p.xz) - 5.70, p.y)) - 0.2;
        
        if(dd < 0.001)
        {
            float a = 0.5 + atan(p.x, p.z) / (2.0 * PI);
            float b = 0.5 - asin(p.y / length(p)) / PI;
            vec3 diff = texture(iChannel6, vec2(-a, -b)).rgb;
            col = diff; 
            break;
        }
        
        ll += dd;
    }  

    // Ring 3
    ll = 0.0;
    
    for(int i = 0; i < 100; i++)
    {
        float orbitRadius = 41.5;              
        float orbitSpeed = 0.32;  
        float orbitAngle = iTime * orbitSpeed;
        vec3 orbitPosition = orbitCenter + vec3(0.0, sin(iTime * orbitSpeed) * orbitRadius, cos(iTime * orbitSpeed) * orbitRadius);
        
        vec3 p = ray_origin + ray_direction * ll - orbitPosition;
        float dd = length(vec2(length(p.xz) - 6.50, p.y)) - 0.2;
        
        if(dd < 0.001)
        {
            float a = 0.5 + atan(p.x, p.z) / (2.0 * PI);
            float b = 0.5 - asin(p.y / length(p)) / PI;
            vec3 diff = texture(iChannel6, vec2(-a, -b)).rgb;
            col = diff; 
            break;
        }
        
        ll += dd;
    }  

    // Uranus
    ll = 0.0;
    
    for(int i = 0; i < 100; i++)
    {
        float orbitRadius = 53.0;                
        float orbitSpeed = 0.22;  
        float orbitAngle = iTime * orbitSpeed;
        vec3 orbitPosition = orbitCenter + vec3(0.0, sin(iTime * orbitSpeed) * orbitRadius, cos(iTime * orbitSpeed) * orbitRadius);
        
        vec3 p = ray_origin + ray_direction * ll - orbitPosition;
        float dd = length(p) - 3.2;
        
        if(dd < 0.001)
        {
            p.xz *= mat2(cos(-iTime * 2.0), -sin(-iTime * 2.0), sin(-iTime * 2.0), cos(-iTime * 2.0)); 
            float a = 0.5 + atan(p.x, p.z) / (2.0 * PI);
            float b = 0.5 - asin(p.y / length(p)) / PI;
            vec3 diff = texture(iChannel7, vec2(-a, -b)).rgb;
            col = diff; 
            break;
        }
        
        ll += dd;
    }

    // Neptune
    ll = 0.0;
    
    for(int i = 0; i < 100; i++)
    {
        float orbitRadius = 64.0;             
        float orbitSpeed = 0.18;  
        float orbitAngle = iTime * orbitSpeed;
        vec3 orbitPosition = orbitCenter + vec3(0.0, sin(iTime * orbitSpeed) * orbitRadius, cos(iTime * orbitSpeed) * orbitRadius);
        
        vec3 p = ray_origin + ray_direction * ll - orbitPosition;
        float dd = length(p) - 3.0;
        
        if(dd < 0.001)
        {
            p.xz *= mat2(cos(-iTime * 1.5), -sin(-iTime * 1.5), sin(-iTime * 1.5), cos(-iTime * 1.5)); 
            float a = 0.5 + atan(p.x, p.z) / (2.0 * PI);
            float b = 0.5 - asin(p.y / length(p)) / PI;
            vec3 diff = texture(iChannel8, vec2(-a, -b)).rgb;
            col = diff; 
            break;
        }
        
        ll += dd;
    }

    // Sun
    ll = 0.0;
    
    for(int i = 0; i < 100; i++)
    {
        vec3 p = ray_origin + ray_direction * ll;
        float dd = length(p) - 9.0;
        
        if(dd < 0.001)
        {
            p.xz *= mat2(cos(-iTime * 2.0), -sin(-iTime * 2.0), sin(-iTime * 2.0), cos(-iTime * 2.0)); 
            float a = 0.5 + atan(p.x, p.z) / (2.0 * PI);
            float b = 0.5 - asin(p.y / length(p)) / PI;
            vec3 diff = texture(iChannel9, vec2(-a, -b)).rgb;
            col += diff; 
            break;
        }
        
        ll += dd;
    }

    // Pluto
    // ll = 0.0;
    
    // for(int i = 0; i < 100; i++)
    // {
    //     float orbitRadius = 72.0;             
    //     float orbitSpeed = 0.95;  
    //     float orbitAngle = iTime * orbitSpeed;
    //     vec3 orbitPosition = orbitCenter + vec3(0.0, sin(iTime * orbitSpeed) * orbitRadius, cos(iTime * orbitSpeed) * orbitRadius);
        
    //     vec3 p = ray_origin + ray_direction * ll - orbitPosition;
    //     float dd = length(p) - 0.2;
        
    //     if(dd < 0.001)
    //     {
    //         p.xz *= mat2(cos(-iTime * 0.5), -sin(-iTime * 0.5), sin(-iTime * 0.5), cos(-iTime * 0.5)); 
    //         float a = 0.5 + atan(p.x, p.z) / (2.0 * PI);
    //         float b = 0.5 - asin(p.y / length(p)) / PI;
    //         vec3 diff = texture(iChannel4, vec2(-a, -b)).rgb;
    //         col += diff; 
    //         break;
    //     }
        
    //     ll += dd;
    // }

    fragColor += vec4(col,1.0);
}