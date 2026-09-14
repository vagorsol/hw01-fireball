#version 300 es 

precision highp float;

uniform vec4 u_ColorPrimary;
uniform vec4 u_ColorSecondary; 

uniform float u_Time;

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

float hash(float p) { p = fract(p * 0.011); p *= p + 7.5; p *= p + p; return fract(p); }
float hash(vec2 p) {vec3 p3 = fract(vec3(p.xyx) * 0.13); p3 += dot(p3, p3.yzx + 3.333); return fract((p3.x + p3.y) * p3.z); }                 

float impulse(float k, float x);
vec3 random3(vec3 p);
float noise(vec3 p);
float fbm(vec3 p, int octaves, float freq, float amp);

void main()
{
    vec4 diffuseColor;

    float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec)); // Calculate the diffuse term for Lambert shading
    diffuseTerm = clamp(diffuseTerm, 0.0, 1.0); // Avoid negative lighting values
    float ambientTerm = 0.2;
    float lightIntensity = diffuseTerm + ambientTerm; 

    float n = fbm(
        vec3(fs_Pos.x + sin(u_Time), fs_Pos.y + u_Time, fs_Pos.z),
        3, 1.0, 0.5);
    diffuseColor = mix(u_ColorPrimary, u_ColorSecondary, n);

    // linear gradient
    float gradientValue = impulse(0.3, fs_Pos.y);
    vec4 gradientColor = mix(u_ColorPrimary, u_ColorSecondary, gradientValue); 

    //diffuseColor = gradientColor;
    diffuseColor = mix(diffuseColor, gradientColor, 0.35);

    // Compute final shaded color
    out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
}

float impulse(float k, float x) {
    float h = k * x;
    return h * exp(1.0 - h);
}

vec3 random3(vec3 p) {
    return fract(sin(vec3(
        dot(p, vec3(127.1, 311.7, 113.0)),
        dot(p, vec3(269.5, 183.3, 1.0)),
        dot(p, vec3(419.2, 371.9, 57.0)))
        * 43758.5453));
}

float noise(vec3 p) {
    const vec3 step = vec3(110.0, 241.0, 171.0);

    vec3 pInt = floor(p);
    vec3 pFract = fract(p);

    float n = dot(pInt, step);

    vec3 u = pFract * pFract * (3.0 - 2.0 * pFract);
    return mix(mix(mix( hash(n + dot(step, vec3(0, 0, 0))), hash(n + dot(step, vec3(1, 0, 0))), u.x),
                  mix( hash(n + dot(step, vec3(0, 1, 0))), hash(n + dot(step, vec3(1, 1, 0))), u.x), u.y),
               mix(mix( hash(n + dot(step, vec3(0, 0, 1))), hash(n + dot(step, vec3(1, 0, 1))), u.x),
                   mix( hash(n + dot(step, vec3(0, 1, 1))), hash(n + dot(step, vec3(1, 1, 1))), u.x), u.y), u.z);   
}

float fbm(vec3 p, int octaves, float freq, float amp) {
    float value = 0.0;
    for (int i = 0; i < octaves; ++i) {
        value += amp * noise(p);
        p *= 2.0;
        amp *= 0.5;
    }
    return value; 
}