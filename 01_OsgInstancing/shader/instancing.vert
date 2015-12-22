#version 150 compatibility

in vec4 boneWeight0;
in vec4 boneWeight1;
in vec4 boneWeight2;
in vec4 boneWeight3;

uniform int  nbBonesPerVertex;
uniform mat4 matrixPalette[MAX_MATRIX];

vec4 g_position;
vec3 g_normal;

uniform mat4 instanceModelMatrix[MAX_INSTANCES];

smooth out vec2 texCoord;
smooth out vec3 normal;
smooth out vec3 lightDir;

// accumulate position and normal in global scope
void computeAcummulatedNormalAndPosition(vec4 boneWeight)
{
    int matrixIndex;
    float matrixWeight;
    for (int i = 0; i < 2; i++)
    {
        matrixIndex =  int(boneWeight[0]);
        matrixWeight = boneWeight[1];
        mat4 matrix = matrixPalette[matrixIndex];
        // correct for normal if no scale in bone
        mat3 matrixNormal = mat3(matrix);
        g_position += matrixWeight * (matrix * gl_Vertex );
        g_normal += matrixWeight * (matrixNormal * gl_Normal );

        boneWeight = boneWeight.zwxy;
    }
}

void main()
{
///  from skining animation 
    g_position = vec4(0.0,0.0,0.0,0.0);
    g_normal   = vec3(0.0,0.0,0.0);

    // there is 2 bone data per attributes
    if (nbBonesPerVertex > 0)
        computeAcummulatedNormalAndPosition(boneWeight0);
    if (nbBonesPerVertex > 2)
        computeAcummulatedNormalAndPosition(boneWeight1);
    if (nbBonesPerVertex > 4)
        computeAcummulatedNormalAndPosition(boneWeight2);
    if (nbBonesPerVertex > 6)
        computeAcummulatedNormalAndPosition(boneWeight3);

    // normal = gl_NormalMatrix * normal;

///  from skining animation ///  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


	mat4 _instanceModelMatrix = instanceModelMatrix[gl_InstanceID];
	gl_Position = gl_ModelViewProjectionMatrix * _instanceModelMatrix * /*gl_Vertex*/g_position;
	texCoord = gl_MultiTexCoord0.xy;

	mat3 normalMatrix = mat3(_instanceModelMatrix[0][0], _instanceModelMatrix[0][1], _instanceModelMatrix[0][2],
							 _instanceModelMatrix[1][0], _instanceModelMatrix[1][1], _instanceModelMatrix[1][2],
							 _instanceModelMatrix[2][0], _instanceModelMatrix[2][1], _instanceModelMatrix[2][2]);

	normal = gl_NormalMatrix * normalMatrix * /*gl_Normal*/g_normal;
	lightDir = gl_LightSource[0].position.xyz;
}