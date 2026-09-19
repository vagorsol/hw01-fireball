#version 300 es

precision highp float;

uniform vec4 u_ColorPrimary; 
uniform float u_Time;

in vec2 fs_Pos; 

out vec4 out_Col;

vec3 random3(vec3 p);
float worleyNoise(vec3 p);
float noise2d(vec2 x);

void main()
{
    vec4 topColor = vec4(vec3(0.0), 1.0);
    vec4 col = u_ColorPrimary;

    float noise = worleyNoise(vec3(fs_Pos * 1.5, u_Time * 0.25));
    col = mix(col, vec4(vec3(noise), 1.0), 0.35);

    float threshold = 0.97;
    float star = noise2d(fs_Pos);
    star = (star >= threshold) ? pow((star - threshold) / (1.0 - threshold), 6.0) : 0.0;

    vec4 gradient = mix(u_ColorPrimary, topColor, fs_Pos.y);
    col = mix(col, gradient, 0.45);
    col += vec4(vec3(star), 1.0);
    out_Col = col;
}

vec3 random3(vec3 p) {
    return fract(
        sin(vec3(
        dot(p, vec3(127.1, 311.7, 113.0)),
        dot(p, vec3(269.5, 183.3, 1.0)),
        dot(p, vec3(419.2, 371.9, 57.0)))
        * 43758.5453));
}

float worleyNoise(vec3 p) {
    vec3 pInt = floor(p);
    vec3 pFract = fract(p);
    float minDist = sqrt(3.0);    // minimum distance initialized to max 

    for(int z = -1; z <= 1; ++z) {
        for(int y = -1; y <= 1; ++y) {
            for(int x = -1; x <= 1; ++x) {
                vec3 neighbor = vec3(float(x), float(y), float(z)); // direction in which neighbor cell lies
                vec3 point = random3(pInt + neighbor);  // get the Voroni centerpoint for the neighboring cell
                vec3 diff = neighbor + point - pFract;  // distance between fragment coord and neighbor's Voroni point
                float dist = length(diff);
                minDist = min(minDist, dist);
            }
        }
    }

    return minDist;
}

float noise2d(vec2 p) {
    float xhash = cos(p.x * 37.0);
    float yhash = cos(p.y * 57.0);
    return fract(415.92653 * (xhash + yhash));
}

