fixed2 rotateVec2(fixed2 p, float a)
{
    return fixed2(p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a));
}

// -0.99..~0.99のランダム数生成
float rand(float n) 
{
    return frac(sin(n) * 43758.5453123);
}

// 2次元乱数生成
float2 rand2d(fixed2 p)
{
    return frac(fixed2(sin(p.x * 591.32 + p.y * 154.077), cos(p.x * 391.32 + p.y * 49.077)));
}

// 1次元ノイズ生成
float noise1d(float p) 
{
    float fl = floor(p);
    float fc = frac(p);
    return lerp(rand(fl), rand(fl + 1.0), fc);
}
