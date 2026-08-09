-- Based on the structs and enums within Code/ww3d2/w3d_file.cpp/h

--- @class Renegade
local CNC = CNC_RENEGADE

--- @class W3dFileIds
local STATIC = CNC.CreateExport()

--#region Exported Enums

    --- @type EnumBuilderClass
    local enumBuilderClass = CNC.Import( "sh_enum-builder.lua" )

    local enumBuilder = enumBuilderClass:New()

    --- @enum AnimationChannel
    STATIC.ANIMATION_CHANNEL = {
        ANIM_CHANNEL_X               = enumBuilder:Set( 0 ),
        ANIM_CHANNEL_Y               = enumBuilder:Next(),
        ANIM_CHANNEL_Z               = enumBuilder:Next(),
        ANIM_CHANNEL_XR              = enumBuilder:Next(),
        ANIM_CHANNEL_YR              = enumBuilder:Next(),
        ANIM_CHANNEL_ZR              = enumBuilder:Next(),
        ANIM_CHANNEL_Q               = enumBuilder:Next(),
        ANIM_CHANNEL_TIMECODED_X     = enumBuilder:Next(),
        ANIM_CHANNEL_TIMECODED_Y     = enumBuilder:Next(),
        ANIM_CHANNEL_TIMECODED_Z     = enumBuilder:Next(),
        ANIM_CHANNEL_TIMECODED_Q     = enumBuilder:Next(),
        ANIM_CHANNEL_ADAPTIVEDELTA_X = enumBuilder:Next(),
        ANIM_CHANNEL_ADAPTIVEDELTA_Y = enumBuilder:Next(),
        ANIM_CHANNEL_ADAPTIVEDELTA_Z = enumBuilder:Next(),
        ANIM_CHANNEL_ADAPTIVEDELTA_Q = enumBuilder:Next(),
    }
    local animationChannelEnum = STATIC.ANIMATION_CHANNEL

    --- @enum W3dSurfaceTypes
    STATIC.W3D_SURFACE_TYPES = {
        SURFACE_TYPE_LIGHT_METAL              = enumBuilder:Set( 0 ),
        SURFACE_TYPE_HEAVY_METAL              = enumBuilder:Next(),
        SURFACE_TYPE_WATER                    = enumBuilder:Next(),
        SURFACE_TYPE_SAND                     = enumBuilder:Next(),
        SURFACE_TYPE_DIRT                     = enumBuilder:Next(),
        SURFACE_TYPE_MUD                      = enumBuilder:Next(),
        SURFACE_TYPE_GRASS                    = enumBuilder:Next(),
        SURFACE_TYPE_WOOD                     = enumBuilder:Next(),
        SURFACE_TYPE_CONCRETE                 = enumBuilder:Next(),
        SURFACE_TYPE_FLESH                    = enumBuilder:Next(),
        SURFACE_TYPE_ROCK                     = enumBuilder:Next(),
        SURFACE_TYPE_SNOW                     = enumBuilder:Next(),
        SURFACE_TYPE_ICE                      = enumBuilder:Next(),
        SURFACE_TYPE_DEFAULT                  = enumBuilder:Next(),
        SURFACE_TYPE_GLASS                    = enumBuilder:Next(),
        SURFACE_TYPE_CLOTH                    = enumBuilder:Next(),
        SURFACE_TYPE_TIBERIUM_FIELD           = enumBuilder:Next(),
        SURFACE_TYPE_FOLIAGE_PERMEABLE        = enumBuilder:Next(),
        SURFACE_TYPE_GLASS_PERMEABLE          = enumBuilder:Next(),
        SURFACE_TYPE_ICE_PERMEABLE            = enumBuilder:Next(),
        SURFACE_TYPE_CLOTH_PERMEABLE          = enumBuilder:Next(),
        SURFACE_TYPE_ELECTRICAL               = enumBuilder:Next(),
        SURFACE_TYPE_FLAMMABLE                = enumBuilder:Next(),
        SURFACE_TYPE_STEAM                    = enumBuilder:Next(),
        SURFACE_TYPE_ELECTRICAL_PERMEABLE     = enumBuilder:Next(),
        SURFACE_TYPE_FLAMMABLE_PERMEABLE      = enumBuilder:Next(),
        SURFACE_TYPE_STEAM_PERMEABLE          = enumBuilder:Next(),
        SURFACE_TYPE_WATER_PERMEABLE          = enumBuilder:Next(),
        SURFACE_TYPE_TIBERIUM_WATER           = enumBuilder:Next(),
        SURFACE_TYPE_TIBERIUM_WATER_PERMEABLE = enumBuilder:Next(),
        SURFACE_TYPE_UNDERWATER_DIRT          = enumBuilder:Next(),
        SURFACE_TYPE_UNDERWATER_TIBERIUM_DIRT = enumBuilder:Next()
    }
    local w3dSurfaceTypesEnum = STATIC.W3D_SURFACE_TYPES

    --- @enum W3dChunkType
    STATIC.W3D_CHUNK_TYPE = {
        W3D_CHUNK_MESH                                      = enumBuilder:Set( 0x00000000 ), --- Mesh definition 
            W3D_CHUNK_VERTICES                              = enumBuilder:Set( 0x00000002 ), --- array of vertices (array of W3dVectorStruct's)
            W3D_CHUNK_VERTEX_NORMALS                        = enumBuilder:Set( 0x00000003 ), --- array of normals (array of W3dVectorStruct's)
            W3D_CHUNK_MESH_USER_TEXT                        = enumBuilder:Set( 0x0000000C ), --- Text from the MAX comment field (Null terminated string)
            W3D_CHUNK_VERTEX_INFLUENCES                     = enumBuilder:Set( 0x0000000E ), --- Mesh Deformation vertex connections (array of W3dVertInfStruct's)
            W3D_CHUNK_MESH_HEADER3                          = enumBuilder:Set( 0x0000001F ), ---    mesh header contains general info about the mesh. (W3dMeshHeader3Struct)
            W3D_CHUNK_TRIANGLES                             = enumBuilder:Set( 0x00000020 ), --- New improved triangles chunk (array of W3dTriangleStruct's)
            W3D_CHUNK_VERTEX_SHADE_INDICES                  = enumBuilder:Set( 0x00000022 ), --- shade indexes for each vertex (array of uint32's)

            W3D_CHUNK_PRELIT_UNLIT                          = enumBuilder:Set( 0x00000023 ), --- optional unlit material chunk wrapper
            W3D_CHUNK_PRELIT_VERTEX                         = enumBuilder:Set( 0x00000024 ), --- optional vertex-lit material chunk wrapper
            W3D_CHUNK_PRELIT_LIGHTMAP_MULTI_PASS            = enumBuilder:Set( 0x00000025 ), --- optional lightmapped multi-pass material chunk wrapper
            W3D_CHUNK_PRELIT_LIGHTMAP_MULTI_TEXTURE         = enumBuilder:Set( 0x00000026 ), --- optional lightmapped multi-texture material chunk wrapper
                W3D_CHUNK_MATERIAL_INFO                     = enumBuilder:Set( 0x00000028 ), --- materials information, pass count, etc (contains W3dMaterialInfoStruct)
                W3D_CHUNK_SHADERS                           = enumBuilder:Set( 0x00000029 ), --- shaders (array of W3dShaderStruct's)

                W3D_CHUNK_VERTEX_MATERIALS                  = enumBuilder:Set( 0x0000002A ), --- wraps the vertex materials
                    W3D_CHUNK_VERTEX_MATERIAL               = enumBuilder:Set( 0x0000002B ),
                        W3D_CHUNK_VERTEX_MATERIAL_NAME      = enumBuilder:Set( 0x0000002C ), --- vertex material name (NULL-terminated string)
                        W3D_CHUNK_VERTEX_MATERIAL_INFO      = enumBuilder:Set( 0x0000002D ), --- W3dVertexMaterialStruct
                        W3D_CHUNK_VERTEX_MAPPER_ARGS0       = enumBuilder:Set( 0x0000002E ), --- Null-terminated string
                        W3D_CHUNK_VERTEX_MAPPER_ARGS1       = enumBuilder:Set( 0x0000002F ), --- Null-terminated string
                W3D_CHUNK_TEXTURES                          = enumBuilder:Set( 0x00000030 ), --- wraps all of the texture info
                    W3D_CHUNK_TEXTURE                       = enumBuilder:Set( 0x00000031 ), --- wraps a texture definition
                        W3D_CHUNK_TEXTURE_NAME              = enumBuilder:Set( 0x00000032 ), --- texture filename (NULL-terminated string)
                        W3D_CHUNK_TEXTURE_INFO              = enumBuilder:Set( 0x00000033 ), --- optional W3dTextureInfoStruct

                W3D_CHUNK_MATERIAL_PASS                     = enumBuilder:Set( 0x00000038 ), --- wraps the information for a single material pass
                    W3D_CHUNK_VERTEX_MATERIAL_IDS           = enumBuilder:Set( 0x00000039 ), --- single or per-vertex array of uint32 vertex material indices (check chunk size)
                    W3D_CHUNK_SHADER_IDS                    = enumBuilder:Set( 0x0000003A ), --- single or per-tri array of uint32 shader indices (check chunk size)
                    W3D_CHUNK_DCG                           = enumBuilder:Set( 0x0000003B ), --- per-vertex diffuse color values (array of W3dRGBAStruct's)
                    W3D_CHUNK_DIG                           = enumBuilder:Set( 0x0000003C ), --- per-vertex diffuse illumination values (array of W3dRGBStruct's)
                    W3D_CHUNK_SCG                           = enumBuilder:Set( 0x0000003E ), --- per-vertex specular color values (array of W3dRGBStruct's)
                    W3D_CHUNK_TEXTURE_STAGE                 = enumBuilder:Set( 0x00000048 ), --- wrapper around a texture stage.
                        W3D_CHUNK_TEXTURE_IDS               = enumBuilder:Set( 0x00000049 ), --- single or per-tri array of uint32 texture indices (check chunk size)
                        W3D_CHUNK_STAGE_TEXCOORDS           = enumBuilder:Set( 0x0000004A ), --- per-vertex texture coordinates (array of W3dTexCoordStruct's)
                        W3D_CHUNK_PER_FACE_TEXCOORD_IDS     = enumBuilder:Set( 0x0000004B ), --- indices to W3D_CHUNK_STAGE_TEXCOORDS, (array of Vector3i)
            W3D_CHUNK_DEFORM                                = enumBuilder:Set( 0x00000058 ), --- mesh deform or 'damage' information.
                W3D_CHUNK_DEFORM_SET                        = enumBuilder:Set( 0x00000059 ), --- set of deform information
                    W3D_CHUNK_DEFORM_KEYFRAME               = enumBuilder:Set( 0x0000005A ), --- a keyframe of deform information in the set
                        W3D_CHUNK_DEFORM_DATA               = enumBuilder:Set( 0x0000005B ), --- deform information about a single vertex
            W3D_CHUNK_PS2_SHADERS                           = enumBuilder:Set( 0x00000080 ), --- Shader info specific to the Playstation 2.

            W3D_CHUNK_AABTREE                               = enumBuilder:Set( 0x00000090 ), --- Axis-Aligned Box Tree for hierarchical polygon culling
                W3D_CHUNK_AABTREE_HEADER                    = enumBuilder:Next(),                   --- catalog of the contents of the AABTree
                W3D_CHUNK_AABTREE_POLYINDICES               = enumBuilder:Next(),                   --- array of uint32 polygon indices with count=mesh.PolyCount
                W3D_CHUNK_AABTREE_NODES                     = enumBuilder:Next(),                   --- array of W3dMeshAABTreeNode's with count=aabheader.NodeCount
        W3D_CHUNK_HIERARCHY                                 = enumBuilder:Set( 0x00000100 ), --- hierarchy tree definition
            W3D_CHUNK_HIERARCHY_HEADER                      = enumBuilder:Next(),
            W3D_CHUNK_PIVOTS                                = enumBuilder:Next(),
            W3D_CHUNK_PIVOT_FIXUPS                          = enumBuilder:Next(),                   --- only needed by the exporter...

        W3D_CHUNK_ANIMATION                                 = enumBuilder:Set( 0x00000200 ), --- hierarchy animation data
            W3D_CHUNK_ANIMATION_HEADER                      = enumBuilder:Next(),
            W3D_CHUNK_ANIMATION_CHANNEL                     = enumBuilder:Next(),                   --- channel of vectors
            W3D_CHUNK_BIT_CHANNEL                           = enumBuilder:Next(),                   --- channel of boolean values (e.g. visibility)
        W3D_CHUNK_COMPRESSED_ANIMATION                      = enumBuilder:Set( 0x00000280 ), --- compressed hierarchy animation data
            W3D_CHUNK_COMPRESSED_ANIMATION_HEADER           = enumBuilder:Next(),                   --- describes playback rate, number of frames, and type of compression
            W3D_CHUNK_COMPRESSED_ANIMATION_CHANNEL          = enumBuilder:Next(),                   --- compressed channel, format dependent on type of compression
            W3D_CHUNK_COMPRESSED_BIT_CHANNEL                = enumBuilder:Next(),                   --- compressed bit stream channel, format dependent on type of compression
            
        W3D_CHUNK_MORPH_ANIMATION                           = enumBuilder:Set( 0x000002C0 ), --- hierarchy morphing animation data (morphs between poses, for facial animation)
            W3D_CHUNK_MORPHANIM_HEADER                      = enumBuilder:Next(),                   --- W3dMorphAnimHeaderStruct describes playback rate, number of frames, and type of compression
            W3D_CHUNK_MORPHANIM_CHANNEL                     = enumBuilder:Next(),                   --- wrapper for a channel
                W3D_CHUNK_MORPHANIM_POSENAME                = enumBuilder:Next(),                   --- name of the other anim which contains the poses for this morph channel
                W3D_CHUNK_MORPHANIM_KEYDATA                 = enumBuilder:Next(),                   --- morph key data for this channel
            W3D_CHUNK_MORPHANIM_PIVOTCHANNELDATA            = enumBuilder:Next(),                   --- uin32 per pivot in the htree, indicating which channel controls the pivot
        W3D_CHUNK_HMODEL                                    = enumBuilder:Set( 0x00000300 ), --- blueprint for a hierarchy model
            W3D_CHUNK_HMODEL_HEADER                         = enumBuilder:Next(),                   --- Header for the hierarchy model
            W3D_CHUNK_NODE                                  = enumBuilder:Next(),                   --- render objects connected to the hierarchy
            W3D_CHUNK_COLLISION_NODE                        = enumBuilder:Next(),                   --- collision meshes connected to the hierarchy
            W3D_CHUNK_SKIN_NODE                             = enumBuilder:Next(),                   --- skins connected to the hierarchy
            OBSOLETE_W3D_CHUNK_HMODEL_AUX_DATA              = enumBuilder:Next(),                   --- extension of the hierarchy model header
            OBSOLETE_W3D_CHUNK_SHADOW_NODE                  = enumBuilder:Next(),                   --- shadow object connected to the hierarchy
        W3D_CHUNK_LODMODEL                                  = enumBuilder:Set( 0x00000400 ), --- blueprint for an LOD model.  This is simply a
            W3D_CHUNK_LODMODEL_HEADER                       = enumBuilder:Next(),                   --- collection of 'n' render objects, ordered in terms
            W3D_CHUNK_LOD                                   = enumBuilder:Next(),                   --- of their expected rendering costs. (highest is first)
        W3D_CHUNK_COLLECTION                                = enumBuilder:Set( 0x00000420 ), --- collection of render object names
            W3D_CHUNK_COLLECTION_HEADER                     = enumBuilder:Next(),                   --- general info regarding the collection
            W3D_CHUNK_COLLECTION_OBJ_NAME                   = enumBuilder:Next(),                   --- contains a string which is the name of a render object
            W3D_CHUNK_PLACEHOLDER                           = enumBuilder:Next(),                   --- contains information about a 'dummy' object that will be instanced later
            W3D_CHUNK_TRANSFORM_NODE                        = enumBuilder:Next(),                   --- contains the filename of another w3d file that should be transformed by this node
        W3D_CHUNK_POINTS                                    = enumBuilder:Set( 0x00000440 ), --- array of W3dVectorStruct's.  May appear in meshes, hmodels, lodmodels, or collections.
        W3D_CHUNK_LIGHT                                     = enumBuilder:Set( 0x00000460 ), --- description of a light
            W3D_CHUNK_LIGHT_INFO                            = enumBuilder:Next(),                   --- generic light parameters
            W3D_CHUNK_SPOT_LIGHT_INFO                       = enumBuilder:Next(),                   --- extra spot light parameters
            W3D_CHUNK_NEAR_ATTENUATION                      = enumBuilder:Next(),                   --- optional near attenuation parameters
            W3D_CHUNK_FAR_ATTENUATION                       = enumBuilder:Next(),                   --- optional far attenuation parameters
        W3D_CHUNK_EMITTER                                   = enumBuilder:Set( 0x00000500 ), --- description of a particle emitter
            W3D_CHUNK_EMITTER_HEADER                        = enumBuilder:Next(),                   --- general information such as name and version
            W3D_CHUNK_EMITTER_USER_DATA                     = enumBuilder:Next(),                   --- user-defined data that specific loaders can switch on
            W3D_CHUNK_EMITTER_INFO                          = enumBuilder:Next(),                   --- generic particle emitter definition
            W3D_CHUNK_EMITTER_INFOV2                        = enumBuilder:Next(),                   --- generic particle emitter definition (version 2.0)
            W3D_CHUNK_EMITTER_PROPS                         = enumBuilder:Next(),                   --- Key-frameable properties
            OBSOLETE_W3D_CHUNK_EMITTER_COLOR_KEYFRAME       = enumBuilder:Next(),                   --- structure defining a single color keyframe
            OBSOLETE_W3D_CHUNK_EMITTER_OPACITY_KEYFRAME     = enumBuilder:Next(),                   --- structure defining a single opacity keyframe
            OBSOLETE_W3D_CHUNK_EMITTER_SIZE_KEYFRAME        = enumBuilder:Next(),                   --- structure defining a single size keyframe
            W3D_CHUNK_EMITTER_LINE_PROPERTIES               = enumBuilder:Next(),                   --- line properties, used by line rendering mode
            W3D_CHUNK_EMITTER_ROTATION_KEYFRAMES            = enumBuilder:Next(),                   --- rotation keys for the particles
            W3D_CHUNK_EMITTER_FRAME_KEYFRAMES               = enumBuilder:Next(),                   --- frame keys (u-v based frame animation)
            W3D_CHUNK_EMITTER_BLUR_TIME_KEYFRAMES           = enumBuilder:Next(),                   --- length of tail for line groups
        W3D_CHUNK_AGGREGATE                                 = enumBuilder:Set( 0x00000600 ), --- description of an aggregate object
            W3D_CHUNK_AGGREGATE_HEADER                      = enumBuilder:Next(),                   --- general information such as name and version
                W3D_CHUNK_AGGREGATE_INFO                    = enumBuilder:Next(),                   --- references to 'contained' models
            W3D_CHUNK_TEXTURE_REPLACER_INFO                 = enumBuilder:Next(),                   --- information about which meshes need textures replaced
            W3D_CHUNK_AGGREGATE_CLASS_INFO                  = enumBuilder:Next(),                   --- information about the original class that created this aggregate
        W3D_CHUNK_HLOD                                      = enumBuilder:Set( 0x00000700 ), --- description of an HLod object (see HLodClass)
            W3D_CHUNK_HLOD_HEADER                           = enumBuilder:Next(),                   --- general information such as name and version
            W3D_CHUNK_HLOD_LOD_ARRAY                        = enumBuilder:Next(),                   --- wrapper around the array of objects for each level of detail
                W3D_CHUNK_HLOD_SUB_OBJECT_ARRAY_HEADER      = enumBuilder:Next(),                   --- info on the objects in this level of detail array
                W3D_CHUNK_HLOD_SUB_OBJECT                   = enumBuilder:Next(),                   --- an object in this level of detail array
            W3D_CHUNK_HLOD_AGGREGATE_ARRAY                  = enumBuilder:Next(),                   --- array of aggregates, contains W3D_CHUNK_SUB_OBJECT_ARRAY_HEADER and W3D_CHUNK_SUB_OBJECT_ARRAY
            W3D_CHUNK_HLOD_PROXY_ARRAY                      = enumBuilder:Next(),                   --- array of proxies, used for application-defined purposes, provides a name and a bone.
        W3D_CHUNK_BOX                                       = enumBuilder:Set( 0x00000740 ), --- defines an collision box render object (W3dBoxStruct)
        W3D_CHUNK_SPHERE                                    = enumBuilder:Next(),
        W3D_CHUNK_RING                                      = enumBuilder:Next(),
        W3D_CHUNK_NULL_OBJECT                               = enumBuilder:Set( 0x00000750 ), --- defines a NULL object (W3dNullObjectStruct)
        W3D_CHUNK_LIGHTSCAPE                                = enumBuilder:Set( 0x00000800 ), --- wrapper for lights created with Lightscape.    
            W3D_CHUNK_LIGHTSCAPE_LIGHT                      = enumBuilder:Next(),                   --- definition of a light created with Lightscape.
                W3D_CHUNK_LIGHT_TRANSFORM                   = enumBuilder:Next(),                   --- position and orientation (defined as right-handed 4x3 matrix transform W3dLightTransformStruct).
        W3D_CHUNK_DAZZLE                                    = enumBuilder:Set( 0x00000900 ), --- wrapper for a glare object.  Creates halos and flare lines seen around a bright light source
            W3D_CHUNK_DAZZLE_NAME                           = enumBuilder:Next(),                   --- null-terminated string, name of the dazzle (typical w3d object naming: "container.object")
            W3D_CHUNK_DAZZLE_TYPENAME                       = enumBuilder:Next(),                   --- null-terminated string, type of dazzle (from dazzle.ini)
        W3D_CHUNK_SOUNDROBJ                                 = enumBuilder:Set( 0x00000A00 ), --- description of a sound render object
            W3D_CHUNK_SOUNDROBJ_HEADER                      = enumBuilder:Next(),                   --- general information such as name and version
            W3D_CHUNK_SOUNDROBJ_DEFINITION                  = enumBuilder:Next(),                   --- chunk containing the definition of the sound that is to play    
    }
    local w3dChunkTypeEnum = STATIC.W3D_CHUNK_TYPE

    --- @enum W3dShaderBits
    STATIC.W3D_SHADER_BITS = {
        W3DSHADER_DEPTHCOMPARE_PASS_NEVER = enumBuilder:Set( 0 ), -- "pass never (i.e. always fail depth comparison test)"
        W3DSHADER_DEPTHCOMPARE_PASS_LESS     = enumBuilder:Next(), -- "pass if incoming less than stored"
        W3DSHADER_DEPTHCOMPARE_PASS_EQUAL    = enumBuilder:Next(), -- "pass if incoming equal to stored"
        W3DSHADER_DEPTHCOMPARE_PASS_LEQUAL   = enumBuilder:Next(), -- "pass if incoming less than or equal to stored (default)"
        W3DSHADER_DEPTHCOMPARE_PASS_GREATER  = enumBuilder:Next(), -- "pass if incoming greater than stored	"
        W3DSHADER_DEPTHCOMPARE_PASS_NOTEQUAL = enumBuilder:Next(), -- "pass if incoming not equal to stored"
        W3DSHADER_DEPTHCOMPARE_PASS_GEQUAL   = enumBuilder:Next(), -- "pass if incoming greater than or equal to stored"
        W3DSHADER_DEPTHCOMPARE_PASS_ALWAYS   = enumBuilder:Next(), -- "pass always"
        W3DSHADER_DEPTHCOMPARE_PASS_MAX      = enumBuilder:Next(), -- "end of enumeration"

        W3DSHADER_DEPTHMASK_WRITE_DISABLE = enumBuilder:Set( 0 ), -- "disable depth buffer writes "
        W3DSHADER_DEPTHMASK_WRITE_ENABLE  = enumBuilder:Next(), -- "enable depth buffer writes (default)"
        W3DSHADER_DEPTHMASK_WRITE_MAX     = enumBuilder:Next(), -- "end of enumeration"

        W3DSHADER_ALPHATEST_DISABLE = enumBuilder:Set( 0 ), -- "disable alpha testing (default)"
        W3DSHADER_ALPHATEST_ENABLE  = enumBuilder:Next(), -- "enable alpha testing"
        W3DSHADER_ALPHATEST_MAX     = enumBuilder:Next(), -- "end of enumeration"

        W3DSHADER_DESTBLENDFUNC_ZERO = enumBuilder:Set( 0 ), -- "destination pixel doesn't affect blending (default)"
        W3DSHADER_DESTBLENDFUNC_ONE                 = enumBuilder:Next(), -- "destination pixel added unmodified"
        W3DSHADER_DESTBLENDFUNC_SRC_COLOR           = enumBuilder:Next(), -- "destination pixel multiplied by fragment RGB components"
        W3DSHADER_DESTBLENDFUNC_ONE_MINUS_SRC_COLOR = enumBuilder:Next(), -- "destination pixel multiplied by one minus (i.e. inverse) fragment RGB components"
        W3DSHADER_DESTBLENDFUNC_SRC_ALPHA           = enumBuilder:Next(), -- "destination pixel multiplied by fragment alpha component"
        W3DSHADER_DESTBLENDFUNC_ONE_MINUS_SRC_ALPHA = enumBuilder:Next(), -- "destination pixel multiplied by fragment inverse alpha"
        W3DSHADER_DESTBLENDFUNC_SRC_COLOR_PREFOG    = enumBuilder:Next(), -- "destination pixel multiplied by fragment RGB components prior to fogging"
        W3DSHADER_DESTBLENDFUNC_MAX                 = enumBuilder:Next(), -- "end of enumeration"

        W3DSHADER_PRIGRADIENT_DISABLE = enumBuilder:Set( 0 ), -- "disable primary gradient (same as OpenGL 'decal' texture blend)"
        W3DSHADER_PRIGRADIENT_MODULATE   = enumBuilder:Next(), -- "modulate fragment ARGB by gradient ARGB (default)"
        W3DSHADER_PRIGRADIENT_ADD        = enumBuilder:Next(), -- "add gradient RGB to fragment RGB, copy gradient A to fragment A"
        W3DSHADER_PRIGRADIENT_BUMPENVMAP = enumBuilder:Next(), -- "environment-mapped bump mapping"
        W3DSHADER_PRIGRADIENT_MAX        = enumBuilder:Next(), -- "end of enumeration"

        W3DSHADER_SECGRADIENT_DISABLE = enumBuilder:Set( 0 ), -- "don't draw secondary gradient (default)"
        W3DSHADER_SECGRADIENT_ENABLE  = enumBuilder:Next(), -- "add secondary gradient RGB to fragment RGB "
        W3DSHADER_SECGRADIENT_MAX     = enumBuilder:Next(), -- "end of enumeration"

        W3DSHADER_SRCBLENDFUNC_ZERO = enumBuilder:Set( 0 ), -- "fragment not added to color buffer"
        W3DSHADER_SRCBLENDFUNC_ONE                 = enumBuilder:Next(), -- "fragment added unmodified to color buffer (default)"
        W3DSHADER_SRCBLENDFUNC_SRC_ALPHA           = enumBuilder:Next(), -- "fragment RGB components multiplied by fragment A"
        W3DSHADER_SRCBLENDFUNC_ONE_MINUS_SRC_ALPHA = enumBuilder:Next(), -- "fragment RGB components multiplied by fragment inverse (one minus) A"
        W3DSHADER_SRCBLENDFUNC_MAX                 = enumBuilder:Next(), -- "end of enumeration"

        W3DSHADER_TEXTURING_DISABLE = enumBuilder:Set( 0 ), -- "no texturing (treat fragment initial color as 1,1,1,1) (default)"
        W3DSHADER_TEXTURING_ENABLE  = enumBuilder:Next(), -- "enable texturing"
        W3DSHADER_TEXTURING_MAX     = enumBuilder:Next(), -- "end of enumeration"

        W3DSHADER_DETAILCOLORFUNC_DISABLE     = enumBuilder:Set( 0 ), -- "local (default)"
        W3DSHADER_DETAILCOLORFUNC_DETAIL      = enumBuilder:Next(), -- "other"
        W3DSHADER_DETAILCOLORFUNC_SCALE       = enumBuilder:Next(), -- "local * other"
        W3DSHADER_DETAILCOLORFUNC_INVSCALE    = enumBuilder:Next(), -- "~(~local * ~other) = local + (1-local)*other"
        W3DSHADER_DETAILCOLORFUNC_ADD         = enumBuilder:Next(), -- "local + other"
        W3DSHADER_DETAILCOLORFUNC_SUB         = enumBuilder:Next(), -- "local - other"
        W3DSHADER_DETAILCOLORFUNC_SUBR        = enumBuilder:Next(), -- "other - local"
        W3DSHADER_DETAILCOLORFUNC_BLEND       = enumBuilder:Next(), -- "(localAlpha)*local + (~localAlpha)*other"
        W3DSHADER_DETAILCOLORFUNC_DETAILBLEND = enumBuilder:Next(), -- "(otherAlpha)*local + (~otherAlpha)*other"
        W3DSHADER_DETAILCOLORFUNC_MAX         = enumBuilder:Next(), -- "end of enumeration"

        W3DSHADER_DETAILALPHAFUNC_DISABLE  = enumBuilder:Set( 0 ), -- "local (default)"
        W3DSHADER_DETAILALPHAFUNC_DETAIL   = enumBuilder:Next(), -- "other"
        W3DSHADER_DETAILALPHAFUNC_SCALE    = enumBuilder:Next(), -- "local * other"
        W3DSHADER_DETAILALPHAFUNC_INVSCALE = enumBuilder:Next(), -- "~(~local * ~other) = local + (1-local)*other"
        W3DSHADER_DETAILALPHAFUNC_MAX      = enumBuilder:Next(), -- "end of enumeration"

        W3DSHADER_DEPTHCOMPARE_DEFAULT    = -1,
        W3DSHADER_DEPTHMASK_DEFAULT       = -1,
        W3DSHADER_ALPHATEST_DEFAULT       = -1,
        W3DSHADER_DESTBLENDFUNC_DEFAULT   = -1,
        W3DSHADER_PRIGRADIENT_DEFAULT     = -1,
        W3DSHADER_SECGRADIENT_DEFAULT     = -1,
        W3DSHADER_SRCBLENDFUNC_DEFAULT    = -1,
        W3DSHADER_TEXTURING_DEFAULT       = -1,
        W3DSHADER_DETAILCOLORFUNC_DEFAULT = -1,
        W3DSHADER_DETAILALPHAFUNC_DEFAULT = -1,
    }
    local w3dShaderBitsEnum = STATIC.W3D_SHADER_BITS
    w3dShaderBitsEnum.W3DSHADER_DEPTHCOMPARE_DEFAULT    = w3dShaderBitsEnum.W3DSHADER_DEPTHCOMPARE_PASS_LEQUAL
    w3dShaderBitsEnum.W3DSHADER_DEPTHMASK_DEFAULT       = w3dShaderBitsEnum.W3DSHADER_DEPTHMASK_WRITE_ENABLE
    w3dShaderBitsEnum.W3DSHADER_ALPHATEST_DEFAULT       = w3dShaderBitsEnum.W3DSHADER_ALPHATEST_DISABLE
    w3dShaderBitsEnum.W3DSHADER_DESTBLENDFUNC_DEFAULT   = w3dShaderBitsEnum.W3DSHADER_DESTBLENDFUNC_ZERO
    w3dShaderBitsEnum.W3DSHADER_PRIGRADIENT_DEFAULT     = w3dShaderBitsEnum.W3DSHADER_PRIGRADIENT_MODULATE
    w3dShaderBitsEnum.W3DSHADER_SECGRADIENT_DEFAULT     = w3dShaderBitsEnum.W3DSHADER_SECGRADIENT_DISABLE
    w3dShaderBitsEnum.W3DSHADER_SRCBLENDFUNC_DEFAULT    = w3dShaderBitsEnum.W3DSHADER_SRCBLENDFUNC_ONE
    w3dShaderBitsEnum.W3DSHADER_TEXTURING_DEFAULT       = w3dShaderBitsEnum.W3DSHADER_TEXTURING_DISABLE
    w3dShaderBitsEnum.W3DSHADER_DETAILCOLORFUNC_DEFAULT = w3dShaderBitsEnum.W3DSHADER_DETAILCOLORFUNC_DISABLE
    w3dShaderBitsEnum.W3DSHADER_DETAILALPHAFUNC_DEFAULT = w3dShaderBitsEnum.W3DSHADER_DETAILALPHAFUNC_DISABLE

--#endregion

--#region Imports

	--- @type DeserializeLib
	local deserializeLib = CNC.Import( "sh_deserialize.lua" )
--#endregion


--#region Imported Enums
    local fundamentalDataTypeEnum = deserializeLib.FUNDAMENTAL_DATA_TYPE
--#endregion


--- "Null objects are used by the LOD system to make meshes disappear at lower levels of detail."
--- @class W3dNullObjectStruct
--- @field Version integer "File format version"
--- @field Attributes integer "Object attributes (currently un-used)"
--- @field Pad integer "Pad space"
--- @field Name string "Name is in the form `<containername>.<boxname>`"


--- @class W3dFileTypes

STATIC.W3D_NAME_LEN = 16

--- @param major integer
--- @param minor integer
--- @return integer
function STATIC.W3D_MAKE_VERSION( major, minor )
    return bit.bor( bit.lshift( major, 16 ), minor )
end


STATIC.SURFACE_TYPE_STRINGS = {
    "Light Metal",
    "Heavy Metal",
    "Water",
    "Sand",
    "Dirt",
    "Mud",
    "Grass",
    "Wood",
    "Concrete",
    "Flesh",
    "Rock",
    "Snow",
    "Ice",
    "Default",
    "Glass",
    "Cloth",
    "Tiberium Field",
    "Foliage Permeable",
    "Glass Permeable",
    "Ice Permeable",
    "Cloth Permeable",
    "Electrical",
    "Electrical Permeable",
    "Flammable",
    "Flammable Permeable",
    "Steam",
    "Steam Permeable",
    "Water Permeable",
    "Tiberium Water",
    "Tiberium Water Permeable",
    "Underwater Dirt",
    "Underwater Tiberium Dirt",
}

--[[ Texture Animation PArameters ]] do

    STATIC.W3DTEXTURE_PUBLISH         = 0x0001 -- "this texture should be "published" (indirected so its changeable in code)"
    STATIC.W3DTEXTURE_RESIZE_OBSOLETE = 0x0002 -- "this texture should be resizeable (OBSOLETE!!!)"
    STATIC.W3DTEXTURE_NO_LOD          = 0x0004 -- "this texture should not have any LOD (mipmapping or resizing)"
    STATIC.W3DTEXTURE_CLAMP_U         = 0x0008 -- "this texture should be clamped on U"
    STATIC.W3DTEXTURE_CLAMP_V         = 0x0010 -- "this texture should be clamped on V"
    STATIC.W3DTEXTURE_ALPHA_BITMAP    = 0x0020 -- "this texture's alpha channel should be collapsed to one bit"
end


--[[ Sort Level ]] do

    STATIC.SORT_LEVEL_NONE = 0
    STATIC.MAX_SORT_LEVEL  = 32
    STATIC.SORT_LEVEL_BIN1 = 20
    STATIC.SORT_LEVEL_BIN2 = 15
    STATIC.SORT_LEVEL_BIN3 = 10
end


--[[ W3D Mesh Flags ]] do

    STATIC.W3D_MESH_FLAG_NONE          = 0x00000000 -- "Plain ole normal mesh"
    STATIC.W3D_MESH_FLAG_COLLISION_BOX = 0x00000001 -- "(Obsolete as of 4.1) mesh is a collision box (should be 8 verts, should be hidden, etc)"
    STATIC.W3D_MESH_FLAG_SKIN          = 0x00000002 -- "(Obsolete as of 4.1) skin mesh "
    STATIC.W3D_MESH_FLAG_SHADOW        = 0x00000004 -- "(Obsolete as of 4.1) intended to be projected as a shadow"
    STATIC.W3D_MESH_FLAG_ALIGNED       = 0x00000008 -- "(Obsolete as of 4.1) always aligns with camera"

    STATIC.W3D_MESH_FLAG_COLLISION_TYPE_MASK       = 0x00000FF0		-- "Mask for the collision type bits"
    STATIC.W3D_MESH_FLAG_COLLISION_TYPE_SHIFT      = 4		        -- "Shifting to get to the collision type bits"
    STATIC.W3D_MESH_FLAG_COLLISION_TYPE_PHYSICAL   = 0x00000010		-- "Physical collisions"
    STATIC.W3D_MESH_FLAG_COLLISION_TYPE_PROJECTILE = 0x00000020		-- "Projectiles (rays) collide with this"
    STATIC.W3D_MESH_FLAG_COLLISION_TYPE_VIS        = 0x00000040		-- "Vis rays collide with this mesh"
    STATIC.W3D_MESH_FLAG_COLLISION_TYPE_CAMERA     = 0x00000080		-- "Camera rays/boxes collide with this mesh"
    STATIC.W3D_MESH_FLAG_COLLISION_TYPE_VEHICLE    = 0x00000100		-- "Vehicles collide with this mesh (and with physical collision meshes)"

    STATIC.W3D_MESH_FLAG_HIDDEN               = 0x00001000 -- "This mesh is hidden by default"
    STATIC.W3D_MESH_FLAG_TWO_SIDED            = 0x00002000 -- "Render both sides of this mesh"
    STATIC.OBSOLETE_W3D_MESH_FLAG_LIGHTMAPPED = 0x00004000 -- "Obsolete lightmapped mesh"

    -- "NOTE: retained for backwards compatibility - use W3D_MESH_FLAG_PRELIT_* instead."
    STATIC.W3D_MESH_FLAG_CAST_SHADOW = 0x00008000 -- "This mesh casts shadows"

    STATIC.W3D_MESH_FLAG_GEOMETRY_TYPE_MASK            = 0x00FF0000 -- "(Introduced with 4.1)"
    STATIC.W3D_MESH_FLAG_GEOMETRY_TYPE_NORMAL          = 0x00000000 -- "(4.1+) Normal mesh geometry"
    STATIC.W3D_MESH_FLAG_GEOMETRY_TYPE_CAMERA_ALIGNED  = 0x00010000 -- "(4.1+) Camera aligned mesh"
    STATIC.W3D_MESH_FLAG_GEOMETRY_TYPE_SKIN            = 0x00020000 -- "(4.1+) Skin mesh"
    STATIC.OBSOLETE_W3D_MESH_FLAG_GEOMETRY_TYPE_SHADOW = 0x00030000 -- "(4.1+) Shadow mesh OBSOLETE!"
    STATIC.W3D_MESH_FLAG_GEOMETRY_TYPE_AABOX           = 0x00040000 -- "(4.1+) AABox OBSOLETE!"
    STATIC.W3D_MESH_FLAG_GEOMETRY_TYPE_OBBOX           = 0x00050000 -- "(4.1+) OBBox OBSOLETE!"
    STATIC.W3D_MESH_FLAG_GEOMETRY_TYPE_CAMERA_ORIENTED = 0x00060000 -- "(4.1+) Camera oriented mesh (points _towards_ camera)"

    STATIC.W3D_MESH_FLAG_PRELIT_MASK                   = 0x0F000000 -- "(4.2+)"
    STATIC.W3D_MESH_FLAG_PRELIT_UNLIT                  = 0x01000000 -- "Mesh contains an unlit material chunk wrapper"
    STATIC.W3D_MESH_FLAG_PRELIT_VERTEX                 = 0x02000000 -- "Mesh contains a precalculated vertex-lit material chunk wrapper "
    STATIC.W3D_MESH_FLAG_PRELIT_LIGHTMAP_MULTI_PASS    = 0x04000000 -- "Mesh contains a precalculated multi-pass lightmapped material chunk wrapper"
    STATIC.W3D_MESH_FLAG_PRELIT_LIGHTMAP_MULTI_TEXTURE = 0x08000000 -- "Mesh contains a precalculated multi-texture lightmapped material chunk wrapper"

    STATIC.W3D_MESH_FLAG_SHATTERABLE = 0x10000000 -- "This mesh is shatterable."
    STATIC.W3D_MESH_FLAG_NPATCHABLE	 = 0x20000000 -- "It is ok to NPatch this mesh"
end


--[[ W3D Vertex Materials ]] do

    STATIC.W3DVERTMAT_USE_DEPTH_CUE            = 0x00000001
    STATIC.W3DVERTMAT_ARGB_EMISSIVE_ONLY       = 0x00000002
    STATIC.W3DVERTMAT_COPY_SPECULAR_TO_DIFFUSE = 0x00000004
    STATIC.W3DVERTMAT_DEPTH_CUE_TO_ALPHA       = 0x00000008

    STATIC.W3DVERTMAT_STAGE0_MAPPING_MASK                 = 0x00FF0000
    STATIC.W3DVERTMAT_STAGE0_MAPPING_UV                   = 0x00000000
    STATIC.W3DVERTMAT_STAGE0_MAPPING_ENVIRONMENT          = 0x00010000
    STATIC.W3DVERTMAT_STAGE0_MAPPING_CHEAP_ENVIRONMENT    = 0x00020000
    STATIC.W3DVERTMAT_STAGE0_MAPPING_SCREEN               = 0x00030000
    STATIC.W3DVERTMAT_STAGE0_MAPPING_LINEAR_OFFSET        = 0x00040000
    STATIC.W3DVERTMAT_STAGE0_MAPPING_SILHOUETTE           = 0x00050000
    STATIC.W3DVERTMAT_STAGE0_MAPPING_SCALE                = 0x00060000
    STATIC.W3DVERTMAT_STAGE0_MAPPING_GRID                 = 0x00070000
    STATIC.W3DVERTMAT_STAGE0_MAPPING_ROTATE               = 0x00080000
    STATIC.W3DVERTMAT_STAGE0_MAPPING_SINE_LINEAR_OFFSET   = 0x00090000
    STATIC.W3DVERTMAT_STAGE0_MAPPING_STEP_LINEAR_OFFSET   = 0x000A0000
    STATIC.W3DVERTMAT_STAGE0_MAPPING_ZIGZAG_LINEAR_OFFSET = 0x000B0000
    STATIC.W3DVERTMAT_STAGE0_MAPPING_WS_CLASSIC_ENV       = 0x000C0000
    STATIC.W3DVERTMAT_STAGE0_MAPPING_WS_ENVIRONMENT       = 0x000D0000
    STATIC.W3DVERTMAT_STAGE0_MAPPING_GRID_CLASSIC_ENV     = 0x000E0000
    STATIC.W3DVERTMAT_STAGE0_MAPPING_GRID_ENVIRONMENT     = 0x000F0000
    STATIC.W3DVERTMAT_STAGE0_MAPPING_RANDOM               = 0x00100000
    STATIC.W3DVERTMAT_STAGE0_MAPPING_EDGE                 = 0x00110000
    STATIC.W3DVERTMAT_STAGE0_MAPPING_BUMPENV              = 0x00120000

    STATIC.W3DVERTMAT_STAGE1_MAPPING_MASK                 = 0x0000FF00
    STATIC.W3DVERTMAT_STAGE1_MAPPING_UV                   = 0x00000000
    STATIC.W3DVERTMAT_STAGE1_MAPPING_ENVIRONMENT          = 0x00000100
    STATIC.W3DVERTMAT_STAGE1_MAPPING_CHEAP_ENVIRONMENT    = 0x00000200
    STATIC.W3DVERTMAT_STAGE1_MAPPING_SCREEN               = 0x00000300
    STATIC.W3DVERTMAT_STAGE1_MAPPING_LINEAR_OFFSET        = 0x00000400
    STATIC.W3DVERTMAT_STAGE1_MAPPING_SILHOUETTE           = 0x00000500
    STATIC.W3DVERTMAT_STAGE1_MAPPING_SCALE                = 0x00000600
    STATIC.W3DVERTMAT_STAGE1_MAPPING_GRID                 = 0x00000700
    STATIC.W3DVERTMAT_STAGE1_MAPPING_ROTATE               = 0x00000800
    STATIC.W3DVERTMAT_STAGE1_MAPPING_SINE_LINEAR_OFFSET   = 0x00000900
    STATIC.W3DVERTMAT_STAGE1_MAPPING_STEP_LINEAR_OFFSET   = 0x00000A00
    STATIC.W3DVERTMAT_STAGE1_MAPPING_ZIGZAG_LINEAR_OFFSET = 0x00000B00
    STATIC.W3DVERTMAT_STAGE1_MAPPING_WS_CLASSIC_ENV       = 0x00000C00
    STATIC.W3DVERTMAT_STAGE1_MAPPING_WS_ENVIRONMENT       = 0x00000D00
    STATIC.W3DVERTMAT_STAGE1_MAPPING_GRID_CLASSIC_ENV     = 0x00000E00
    STATIC.W3DVERTMAT_STAGE1_MAPPING_GRID_ENVIRONMENT     = 0x00000F00
    STATIC.W3DVERTMAT_STAGE1_MAPPING_RANDOM               = 0x00001000
    STATIC.W3DVERTMAT_STAGE1_MAPPING_EDGE                 = 0x00001100
    STATIC.W3DVERTMAT_STAGE1_MAPPING_BUMPENV              = 0x00001200

    STATIC.W3DVERTMAT_PSX_MASK            = 0xFF000000
    STATIC.W3DVERTMAT_PSX_TRANS_MASK      = 0x07000000
    STATIC.W3DVERTMAT_PSX_TRANS_NONE      = 0x00000000
    STATIC.W3DVERTMAT_PSX_TRANS_100       = 0x01000000
    STATIC.W3DVERTMAT_PSX_TRANS_50        = 0x02000000
    STATIC.W3DVERTMAT_PSX_TRANS_25        = 0x03000000
    STATIC.W3DVERTMAT_PSX_TRANS_MINUS_100 = 0x04000000
    STATIC.W3DVERTMAT_PSX_NO_RT_LIGHTING  = 0x08000000
end


--[[ W3D Box Attributes ]] do
    --[[
    "  
    Collision boxes are meant to be used for, you guessed it, collision detection.  
    For this reason, they only contain a minimal amount of rendering information
    (a color).  

    Axis Aligned - This is a bounding box which is *always* aligned with the world 
    coordinate system.  So, the center point is to be transformed by whatever
    transformation matrix is being used but the extents always point down the
    world space x,y, and z axes.  (in effect, you are translating the center).  

    Oriented - This is an oriented 3D box.  It is aligned with the coordinate system
    it is in.  So its extents always point along the local coordinate system axes.  
    "  
    --]]

    STATIC.W3D_BOX_ATTRIBUTE_ORIENTED                  = 0x00000001
    STATIC.W3D_BOX_ATTRIBUTE_ALIGNED                   = 0x00000002
    STATIC.W3D_BOX_ATTRIBUTE_COLLISION_TYPE_MASK       = 0x00000FF0 -- "Mask for the collision type bits"
    STATIC.W3D_BOX_ATTRIBUTE_COLLISION_TYPE_SHIFT      = 4          -- "Shifting to get to the collision type bits"
    STATIC.W3D_BOX_ATTRIBTUE_COLLISION_TYPE_PHYSICAL   = 0x00000010 -- "Physical collisions"
    STATIC.W3D_BOX_ATTRIBTUE_COLLISION_TYPE_PROJECTILE = 0x00000020 -- "Projectiles (rays) collide with this"
    STATIC.W3D_BOX_ATTRIBTUE_COLLISION_TYPE_VIS        = 0x00000040 -- "Vis rays collide with this mesh"
    STATIC.W3D_BOX_ATTRIBTUE_COLLISION_TYPE_CAMERA     = 0x00000080 -- "Cameras collide with this mesh"
    STATIC.W3D_BOX_ATTRIBTUE_COLLISION_TYPE_VEHICLE    = 0x00000100 -- "Vehicles collide with this mesh"
end

--[[ Hierarchical LOD Model (HLod) ]] do

    STATIC.W3D_CURRENT_HLOD_VERSION = STATIC.W3D_MAKE_VERSION( 1, 0 )
    STATIC.NO_MAX_SCREEN_SIZE = math.huge
end

function STATIC.StaticConstructor()

    --- @class W3dQuaternionStruct
    --- @field Q integer[]
    deserializeLib.RegisterComplexDataType( "W3dQuaternionStruct", {
        { Name = "Q", Type = fundamentalDataTypeEnum.Float32, ArrayLength = 4 },
    } )

    --- @class W3dTextureInfoStruct
    --- @field Attributes integer "Flags for this texture"
    --- @field AnimType integer "Animation logic"
    --- @field FrameCount integer "Number of frames (1 if not animated)"
    --- @field FrameRate number "Frame rate, frames per second in floating point"
    deserializeLib.RegisterComplexDataType( "W3dTextureInfoStruct", {
        { Name = "Attributes", Type = fundamentalDataTypeEnum.UInt16  },
        { Name = "AnimType",   Type = fundamentalDataTypeEnum.UInt16  },
        { Name = "FrameCount", Type = fundamentalDataTypeEnum.UInt32  },
        { Name = "FrameRate",  Type = fundamentalDataTypeEnum.Float32 },
    } )

    --- @class W3dShaderStruct
    --- @field DepthCompare integer
    --- @field DepthMask integer
    --- @field ColorMask integer "now obsolete and ignored"
    --- @field DestBlend integer
    --- @field FogFunc integer "now obsolete and ignored"
    --- @field PriGradient integer
    --- @field SecGradient integer
    --- @field SrcBlend integer
    --- @field Texturing integer
    --- @field DetailColorFunc integer
    --- @field DetailAlphaFunc integer
    --- @field ShaderPreset integer "now obsolete and ignored"
    --- @field AlphaTest integer
    --- @field PostDetailColorFunc integer
    --- @field PostDetailAlphaFunc integer
    --- @field Pad integer
    deserializeLib.RegisterComplexDataType( "W3dShaderStruct", {
        { Name = "DepthCompare",        Type = fundamentalDataTypeEnum.UInt8 },
        { Name = "DepthMask",           Type = fundamentalDataTypeEnum.UInt8 },
        { Name = "ColorMask",           Type = fundamentalDataTypeEnum.UInt8 },
        { Name = "DestBlend",           Type = fundamentalDataTypeEnum.UInt8 },
        { Name = "FogFunc",             Type = fundamentalDataTypeEnum.UInt8 },
        { Name = "PriGradient",         Type = fundamentalDataTypeEnum.UInt8 },
        { Name = "SecGradient",         Type = fundamentalDataTypeEnum.UInt8 },
        { Name = "SrcBlend",            Type = fundamentalDataTypeEnum.UInt8 },
        { Name = "Texturing",           Type = fundamentalDataTypeEnum.UInt8 },
        { Name = "DetailColorFunc",     Type = fundamentalDataTypeEnum.UInt8 },
        { Name = "DetailAlphaFunc",     Type = fundamentalDataTypeEnum.UInt8 },
        { Name = "ShaderPreset",        Type = fundamentalDataTypeEnum.UInt8 },
        { Name = "AlphaTest",           Type = fundamentalDataTypeEnum.UInt8 },
        { Name = "PostDetailColorFunc", Type = fundamentalDataTypeEnum.UInt8 },
        { Name = "PostDetailAlphaFunc", Type = fundamentalDataTypeEnum.UInt8 },
        { Name = "Pad",                 Type = fundamentalDataTypeEnum.UInt8 },
    } )

    --- "RGB color, one byte per channel, padded to an even 4 bytes"
    --- @class W3dRGBStruct
    --- @field R integer
    --- @field G integer
    --- @field B integer
    --- @field Pad integer
    deserializeLib.RegisterComplexDataType( "W3dRGBStruct", {
        { Name = "R", Type = fundamentalDataTypeEnum.UInt8 },
        { Name = "G", Type = fundamentalDataTypeEnum.UInt8 },
        { Name = "B", Type = fundamentalDataTypeEnum.UInt8 },
        { Name = "Pad", Type = fundamentalDataTypeEnum.UInt8 },
    } )

    --- @class W3dVertexMaterialStruct
    --- @field Attributes integer  -- "Bitfield for the flags defined above"
    --- @field Ambient W3dRGBStruct
    --- @field Diffuse W3dRGBStruct
    --- @field Specular W3dRGBStruct
    --- @field Emissive W3dRGBStruct
    --- @field Shininess number    -- "How tight the specular highlight will be, 1 - 1000 (default = 1)"
    --- @field Opacity number      -- "How opaque the material is, 0.0 = invisible, 1.0 = fully opaque (default = 1)"
    --- @field Translucency number -- "How much light passes through the material. (default = 0)"
    deserializeLib.RegisterComplexDataType( "W3dVertexMaterialStruct", {
        { Name = "Attributes", Type = fundamentalDataTypeEnum.UInt32 },
        { Name = "Ambient",    Type = "W3dRGBStruct" },
        { Name = "Diffuse",    Type = "W3dRGBStruct" },
        { Name = "Specular",   Type = "W3dRGBStruct" },
        { Name = "Emissive",   Type = "W3dRGBStruct" },
        { Name = "Shininess",    Type = fundamentalDataTypeEnum.Float32 },
        { Name = "Opacity",      Type = fundamentalDataTypeEnum.Float32 },
        { Name = "Translucency", Type = fundamentalDataTypeEnum.Float32 },
    } )

    --- @class W3dVectorStruct
    --- @field X number
    --- @field Y number
    --- @field Z number
    deserializeLib.RegisterComplexDataType( "W3dVectorStruct", {
        { Name = "X", Type = fundamentalDataTypeEnum.Float32 },
        { Name = "Y", Type = fundamentalDataTypeEnum.Float32 },
        { Name = "Z", Type = fundamentalDataTypeEnum.Float32 },
    } )

    --- @class W3dTriStruct
    --- @field Vindex integer[] "Vertex, vnormal, texcoord, color indices"
    --- @field Attributes integer "Attributes bits"
    --- @field Normal W3dVectorStruct "Plane normal"
    --- @field Distance number "Plane distance"
    deserializeLib.RegisterComplexDataType( "W3dTriStruct", {
        { Name = "Vindex",     Type = fundamentalDataTypeEnum.UInt32, ArrayLength = 3 },
        { Name = "Attributes", Type = fundamentalDataTypeEnum.UInt32 },
        { Name = "Normal",     Type = "W3dVectorStruct" },
        { Name = "Distance",   Type = fundamentalDataTypeEnum.Float32 },
    } )

    --- @class W3dTexCoordStruct
    --- @field U number
    --- @field V number
    deserializeLib.RegisterComplexDataType( "W3dTexCoordStruct", {
        { Name = "U", Type = fundamentalDataTypeEnum.Float32 },
        { Name = "V", Type = fundamentalDataTypeEnum.Float32 },
    } )


    --[[ Meshes ]] do
        -- "  
        -- Version 3 Mesh Header, trimmed out some of the junk that was in the previous versions
        -- "  

        STATIC.W3D_CURRENT_MESH_VERSION = STATIC.W3D_MAKE_VERSION( 4, 2 )

        STATIC.W3D_VERTEX_CHANNEL_LOCATION  = 0x00000001 -- "Object-space location of the vertex"
        STATIC.W3D_VERTEX_CHANNEL_NORMAL    = 0x00000002 -- "Object-space normal for the vertex"
        STATIC.W3D_VERTEX_CHANNEL_TEXCOORD  = 0x00000004 -- "Texture coordinate"
        STATIC.W3D_VERTEX_CHANNEL_COLOR     = 0x00000008 -- "vertex color"
        STATIC.W3D_VERTEX_CHANNEL_BONEID    = 0x00000010 -- "Per-vertex bone id for skins"

        STATIC.W3D_FACE_CHANNEL_FACE = 0x00000001	-- "Basic face info, W3dTriStruct..."

        -- "Boundary values for W3dMeshHeaderStruct::SortLevel"
        STATIC.SORT_LEVEL_NONE = 0
        STATIC.MAX_SORT_LEVEL  = 32
        STATIC.SORT_LEVEL_BIN1 = 20
        STATIC.SORT_LEVEL_BIN2 = 15
        STATIC.SORT_LEVEL_BIN3 = 10

        --- @class W3dMeshHeader3Struct
        --- @field Version integer
        --- @field Attributes integer
        --- @field MeshName string
        --- @field ContainerName string
        ---
        --- "Counts, these can be regarded as an inventory of what is to come in the file."
        --- @field NumTris integer "Number of triangles"
        --- @field NumVertices integer "Number of unique vertices"
        --- @field NumMaterials integer "Number of unique materials"
        --- @field SortLevel integer "Static sorting level of this mesh"
        --- @field PreLitVersion integer "Mesh generated by this version of Lightmap Tool"
        --- @field FutureCounts integer "Future counts"
        ---
        --- @field VertexChannels integer "Bits for presence of types of per-vertex info"
        --- @field FaceChannels integer "Bits for presence of type of per-face info"
        --- "Bounding volumes"
        --- @field Min W3dVectorStruct "Min corner of the bounding box"
        --- @field Max W3dVectorStruct "Max corner of the bounding box"
        --- @field SphCenter W3dVectorStruct "Center of bounding sphere"
        --- @field SphRadius number "Bounding sphere radius"
        deserializeLib.RegisterComplexDataType( "W3dMeshHeader3Struct", {
            { Name = "Version",    Type = fundamentalDataTypeEnum.UInt32 },
            { Name = "Attributes", Type = fundamentalDataTypeEnum.UInt32 },

            { Name = "MeshName",      Type = fundamentalDataTypeEnum.String, Size = STATIC.W3D_NAME_LEN },
            { Name = "ContainerName", Type = fundamentalDataTypeEnum.String, Size = STATIC.W3D_NAME_LEN },

            { Name = "NumTris",                 Type = fundamentalDataTypeEnum.UInt32 },
            { Name = "NumVertices",             Type = fundamentalDataTypeEnum.UInt32 },
            { Name = "NumMaterials",            Type = fundamentalDataTypeEnum.UInt32 },
            { Name = "NumDamageStages",         Type = fundamentalDataTypeEnum.UInt32 },
            { Name = "SortLevel",               Type = fundamentalDataTypeEnum.UInt32 },
            { Name = "AttPrelitVersionributes", Type = fundamentalDataTypeEnum.UInt32 },
            { Name = "FutureCounts",            Type = fundamentalDataTypeEnum.UInt32 },

            { Name = "VertexChannels", Type = fundamentalDataTypeEnum.UInt32 },
            { Name = "FaceChannels",   Type = fundamentalDataTypeEnum.UInt32 },

            { Name = "Min",       Type = "W3dVectorStruct" },
            { Name = "Max",       Type = "W3dVectorStruct" },
            { Name = "SphCenter", Type = "W3dVectorStruct" },
            { Name = "SphRadius", Type = fundamentalDataTypeEnum.Float32 },
        } )

        -- "  
        -- Vertex Influences.  
        -- For "skins" each vertex can be associated with a different bone.
        -- "  
        --- @class W3dVertInfStruct
        --- @field BoneIndex integer
        --- @field Pad integer[]
        deserializeLib.RegisterComplexDataType( "W3dVertInfStruct", {
            { Name = "BoneIndex", Type = fundamentalDataTypeEnum.UInt16 },
            { Name = "Pad",       Type = fundamentalDataTypeEnum.UInt8, ArrayLength = 6 },
        } )
    end

    --- @class W3dMaterialInfoStruct
    --- @field PassCount integer "How many material passes this render object uses"
    --- @field VertexMaterialCount integer "how many vertex materials are used"
    --- @field ShaderCount integer "how many shaders are used"
    --- @field TextureCount integer "how many textures are used"
    deserializeLib.RegisterComplexDataType( "W3dMaterialInfoStruct", {
        { Name = "PassCount",           Type = fundamentalDataTypeEnum.UInt32 },
        { Name = "VertexMaterialCount", Type = fundamentalDataTypeEnum.UInt32 },
        { Name = "ShaderCount",         Type = fundamentalDataTypeEnum.UInt32 },
        { Name = "TextureCount",        Type = fundamentalDataTypeEnum.UInt32 },
    } )

    --- @class W3dBoxStruct
    --- @field Version integer "File format version"
    --- @field Attributes integer "Box attributes (above #define's)"
    --- @field Name string "Name is in the form <containername>.<boxname>"
    --- @field Color W3dRGBStruct "Color to use when drawing the box"
    --- @field Center W3dVectorStruct "Center of the box"
    --- @field Extent W3dVectorStruct "Extent of the box"
    deserializeLib.RegisterComplexDataType( "W3dBoxStruct", {
        { Name = "Version",     Type = fundamentalDataTypeEnum.UInt32 },
        { Name = "Attributes",  Type = fundamentalDataTypeEnum.UInt32 },
        { Name = "Name",        Type = fundamentalDataTypeEnum.String, Size = 2 * STATIC.W3D_NAME_LEN },
        { Name = "Color",       Type = "W3dRGBStruct"    },
        { Name = "Center",      Type = "W3dVectorStruct" },
        { Name = "Extent",      Type = "W3dVectorStruct" },
    } )

    --- @class W3dHLodHeaderStruct
    --- @field Version integer
    --- @field LodCount integer
    --- @field Name string
    --- @field HierarchyName string "Name of the hierarchy tree to use (\0 if none)"
    deserializeLib.RegisterComplexDataType( "W3dHLodHeaderStruct", {
        { Name = "Version",       Type = fundamentalDataTypeEnum.UInt32 },
        { Name = "LodCount",      Type = fundamentalDataTypeEnum.UInt32 },
        { Name = "Name",          Type = fundamentalDataTypeEnum.String, Size = STATIC.W3D_NAME_LEN },
        { Name = "HierarchyName", Type = fundamentalDataTypeEnum.String, Size = STATIC.W3D_NAME_LEN },
    } )

    --- @class W3dHLodArrayHeaderStruct
    --- @field ModelCount integer
    --- @field MaxScreenSize number "If model is bigger than this, switch to higher lod."
    deserializeLib.RegisterComplexDataType( "W3dHLodArrayHeaderStruct", {
        { Name = "ModelCount",     Type = fundamentalDataTypeEnum.UInt32  },
        { Name = "MaxScreenSize",  Type = fundamentalDataTypeEnum.Float32 },
    } )

    --- @class W3dHLodSubObjectStruct
    --- @field BoneIndex integer
    --- @field Name string
    deserializeLib.RegisterComplexDataType( "W3dHLodSubObjectStruct", {
        { Name = "BoneIndex", Type = fundamentalDataTypeEnum.UInt32 },
        { Name = "Name",      Type = fundamentalDataTypeEnum.String, Size = STATIC.W3D_NAME_LEN * 2 },
    } )

    --- @class W3dHierarchyStruct
    --- @field Version integer
    --- @field Name string "Name of the hierarchy"
    --- @field NumPivots integer
    --- @field Center W3dVectorStruct
    deserializeLib.RegisterComplexDataType( "W3dHierarchyStruct", {
        { Name = "Version",   Type = fundamentalDataTypeEnum.UInt32 },
        { Name = "Name",      Type = fundamentalDataTypeEnum.String, Size = STATIC.W3D_NAME_LEN },
        { Name = "NumPivots", Type = fundamentalDataTypeEnum.UInt32 },
        { Name = "Center",    Type = "W3dVectorStruct" },
    } )

    --- @class W3dPivotStruct
    --- @field Name string "Name of the node (UR_ARM, LR_LEG, TORSO, etc)"
    --- @field ParentIdx integer "0xffffffff = root pivot; no parent"
    --- @field Translation W3dVectorStruct "Translation to pivot point"
    --- @field EulerAngles W3dVectorStruct "Orientation of the pivot point"
    --- @field Rotation W3dQuaternionStruct "Orientation of the pivot point"
    deserializeLib.RegisterComplexDataType( "W3dPivotStruct", {
        { Name = "Name",        Type = fundamentalDataTypeEnum.String, Size = STATIC.W3D_NAME_LEN },
        { Name = "ParentIdx",   Type = fundamentalDataTypeEnum.UInt32 },
        { Name = "Translation", Type = "W3dVectorStruct" },
        { Name = "EulerAngles", Type = "W3dVectorStruct" },
        { Name = "Rotation",    Type = "W3dQuaternionStruct" },
    } )

    --[[ WHA (Westwood Hierarchy Animations) ]] do

        -- "  
        -- A Hierarchy Animation is a set of data defining deltas from the base 
        -- position of a hierarchy tree.  Translation and Rotation channels can be
        -- attached to any node of the hierarchy tree which the animation is 
        -- associated with.
        -- "  

        STATIC.W3D_CURRENT_HANIM_VERSION            = STATIC.W3D_MAKE_VERSION( 4, 1 )
        STATIC.W3D_CURRENT_COMPRESSED_HANIM_VERSION = STATIC.W3D_MAKE_VERSION( 0, 1 )
        STATIC.W3D_CURRENT_MORPH_HANIM_VERSION      = STATIC.W3D_MAKE_VERSION( 0, 1 )

        --- @class W3dAnimHeaderStruct
        --- @field Version integer
        --- @field Name string
        --- @field HierarchyName string
        --- @field NumFrames integer
        --- @field FrameRate integer
        deserializeLib.RegisterComplexDataType( "W3dAnimHeaderStruct", {
            { Name = "Version",       Type = fundamentalDataTypeEnum.UInt32 },
            { Name = "Name",          Type = fundamentalDataTypeEnum.String, Size = STATIC.W3D_NAME_LEN },
            { Name = "HierarchyName", Type = fundamentalDataTypeEnum.String, Size = STATIC.W3D_NAME_LEN },
            { Name = "NumFrames",     Type = fundamentalDataTypeEnum.UInt32 },
            { Name = "FrameRate",     Type = fundamentalDataTypeEnum.UInt32 },
        } )

        --- @class W3dCompressedAnimHeaderStruct
        --- @field Version integer
        --- @field Name string
        --- @field HierarchyName string
        --- @field NumFrames integer
        --- @field FrameRate integer
        --- @field Flavor integer
        deserializeLib.RegisterComplexDataType( "W3dCompressedAnimHeaderStruct", {
            { Name = "Version",       Type = fundamentalDataTypeEnum.UInt32 },
            { Name = "Name",          Type = fundamentalDataTypeEnum.String, Size = STATIC.W3D_NAME_LEN },
            { Name = "HierarchyName", Type = fundamentalDataTypeEnum.String, Size = STATIC.W3D_NAME_LEN },
            { Name = "NumFrames",     Type = fundamentalDataTypeEnum.UInt32 },
            { Name = "FrameRate",     Type = fundamentalDataTypeEnum.UInt16 },
            { Name = "Flavor",        Type = fundamentalDataTypeEnum.UInt16 },
        } )

        --- @enum AnimationChannelEnum
        STATIC.ANIMATION_CHANNEL = {
            ANIM_CHANNEL_X  = enumBuilder:Set( 0 ),
            ANIM_CHANNEL_Y  = enumBuilder:Next(),
            ANIM_CHANNEL_Z  = enumBuilder:Next(),
            ANIM_CHANNEL_XR = enumBuilder:Next(),
            ANIM_CHANNEL_YR = enumBuilder:Next(),
            ANIM_CHANNEL_ZR = enumBuilder:Next(),
            ANIM_CHANNEL_Q  = enumBuilder:Next(),

            ANIM_CHANNEL_TIMECODED_X = enumBuilder:Next(),
            ANIM_CHANNEL_TIMECODED_Y = enumBuilder:Next(),
            ANIM_CHANNEL_TIMECODED_Z = enumBuilder:Next(),
            ANIM_CHANNEL_TIMECODED_Q = enumBuilder:Next(),

            ANIM_CHANNEL_ADAPTIVEDELTA_X = enumBuilder:Next(),
            ANIM_CHANNEL_ADAPTIVEDELTA_Y = enumBuilder:Next(),
            ANIM_CHANNEL_ADAPTIVEDELTA_Z = enumBuilder:Next(),
            ANIM_CHANNEL_ADAPTIVEDELTA_Q = enumBuilder:Next(),
        }

        --- @enum AnimationFlavor
        STATIC.ANIMATION_FLAVOR = {
            ANIM_FLAVOR_TIMECODED      = enumBuilder:Set( 0 ),
            ANIM_FLAVOR_ADAPTIVE_DELTA = enumBuilder:Next(),
            ANIM_FLAVOR_VALID          = enumBuilder:Next()
        }

        --[[ Classic Structures ]] do

            --- @class W3dAnimChannelStruct
            --- @field FirstFrame integer
            --- @field LastFrame integer
            --- @field VectorLength integer "Length of each vector in this channel"
            --- @field Flags integer "Channel type."
            --- @field Pivot integer "Pivot affected by this channel"
            --- @field pad integer
            --- @field Data number[] "Will be (LastFrame - FirstFrame + 1) * VectorLen long"
            deserializeLib.RegisterComplexDataType( "W3dAnimChannelStruct", {
                { Name = "FirstFrame", Type = fundamentalDataTypeEnum.UInt16 },
                { Name = "LastFrame",  Type = fundamentalDataTypeEnum.UInt16 },
                { Name = "VectorLen",  Type = fundamentalDataTypeEnum.UInt16 },
                { Name = "Flags",      Type = fundamentalDataTypeEnum.UInt16 },
                { Name = "Pivot",      Type = fundamentalDataTypeEnum.UInt16 },
                { Name = "pad",        Type = fundamentalDataTypeEnum.UInt16 },
                { Name = "Data",       Type = fundamentalDataTypeEnum.Float32, ArrayLength = 1 },
            } )


            --- @enum BitChannel
            STATIC.BIT_CHANNEL = {
                BIT_CHANNEL_VIS           = enumBuilder:Set( 0 ), -- "Turn meshes on and off depending on anim frame."
                BIT_CHANNEL_TIMECODED_VIS = enumBuilder:Next(),
            }

            --- @class W3dBitChannelStruct
            --- @field FirstFrame integer "All frames outside "First" and "Last" are assumed = DefaultVal"
            --- @field LastFrame integer
            --- @field Flags integer "Channel type."
            --- @field Pivot integer "Pivot affected by this channel"
            --- @field DefaultVal integer "Default state when outside valid range."
            --- @field Data integer[] "Will be (LastFrame - FirstFrame + 1) / 8 long"
            deserializeLib.RegisterComplexDataType( "W3dBitChannelStruct", {
                { Name = "FirstFrame", Type = fundamentalDataTypeEnum.UInt16 },
                { Name = "LastFrame",  Type = fundamentalDataTypeEnum.UInt16 },
                { Name = "Flags",      Type = fundamentalDataTypeEnum.UInt16 },
                { Name = "Pivot",      Type = fundamentalDataTypeEnum.UInt16 },
                { Name = "DefaultVal", Type = fundamentalDataTypeEnum.UInt8 },
                { Name = "Data",       Type = fundamentalDataTypeEnum.UInt8, ArrayLength = 1 },
            } )
        end

        --[[ Begin Time Coded Structures ]] do
            -- "  
            -- A time code is a uint32 that prefixes each vector
            -- the MSB is used to indicate a binary (non interpolated) movement
            -- "

            STATIC.W3D_TIMECODED_BINARY_MOVEMENT_FLAG = 0x80000000

            --- @class W3dTimeCodedAnimChannelStruct
            --- @field NumTimeCodes integer "Number of time coded entries"
            --- @field Pivot integer "Pivot affected by this channel"
            --- @field VectorLength "Length of each vector in this channel"
            --- @field Flags integer "Channel type."
            --- @field Data integer[] "Will be (NumTimeCodes * ( ( VectorLength * sizeof(uint32) ) + sizeof(uint32) ) )"
            deserializeLib.RegisterComplexDataType( "W3dTimeCodedAnimChannelStruct", {
                { Name = "NumTimeCodes", Type = fundamentalDataTypeEnum.UInt32 },
                { Name = "Pivot",        Type = fundamentalDataTypeEnum.UInt16 },
                { Name = "VectorLength", Type = fundamentalDataTypeEnum.UInt8 },
                { Name = "Flags",        Type = fundamentalDataTypeEnum.UInt8 },
                { Name = "Data",         Type = fundamentalDataTypeEnum.UInt32, ArrayLength = 1 },
            } )

            -- "The bit channel is encoded right into the MSB of each time code"
            STATIC.W3D_TIMECODED_BIT_MASK = 0x80000000

            --- @class W3dTimeCodedBitChannelStruct
            --- @field NumTimeCodes integer "Number of time coded entries"
            --- @field Pivot integer "Pivot affected by this channel"
            --- @field Flags integer "Channel type."
            --- @field DefaultValue integer "Default state when outside valid range"
            --- @field Data integer[] "Will be (NumTimeCodes * sizeof(uint32) )"
            deserializeLib.RegisterComplexDataType( "W3dTimeCodedBitChannelStruct", {
                { Name = "NumTimeCodes", Type = fundamentalDataTypeEnum.UInt32 },
                { Name = "Pivot",        Type = fundamentalDataTypeEnum.UInt16 },
                { Name = "Flags",        Type = fundamentalDataTypeEnum.UInt8 },
                { Name = "DefaultValue", Type = fundamentalDataTypeEnum.UInt8 },
                { Name = "Data",         Type = fundamentalDataTypeEnum.UInt32, ArrayLength = 1 },
            } )
        end

        --[[ AdaptiveDelta Structures ]] do

            --- @class W3dAdaptiveDeltaAnimChannelStruct
            --- @field NumFrames integer "Number of frames of animation"
            --- @field Pivot integer "Pivot affected by this channel"
            --- @field VectorLength integer "Num Channels"
            --- @field Flags integer "Channel type"
            --- @field Scale number "Filter Table Scale"
            --- @field Data integer[] "OpCode Data Stream"
            deserializeLib.RegisterComplexDataType( "W3dAdaptiveDeltaAnimChannelStruct", {
                { Name = "NumFrames", Type = fundamentalDataTypeEnum.UInt32 },
                { Name = "Pivot",        Type = fundamentalDataTypeEnum.UInt16 },
                { Name = "VectorLength", Type = fundamentalDataTypeEnum.UInt8 },
                { Name = "Flags",        Type = fundamentalDataTypeEnum.UInt8 },
                { Name = "Scale",        Type = fundamentalDataTypeEnum.Float },
                { Name = "Data",         Type = fundamentalDataTypeEnum.UInt32, ArrayLength = 1 },
            } )
        end
    end

    --[[ Aggregate Objects ]] do
        -- "  
        -- 	The following structs are used to define aggregates in the w3d file.  An
        -- 'aggregate' is simply a 'shell' that contains references to a hierarchy
        -- model and subobjects to attach to its bones.
        -- "  

        STATIC.W3D_CURRENT_AGGREGATE_VERSION = 0x00010003
        STATIC.MESH_PATH_ENTRIES = 15
        STATIC.MESH_PATH_ENTRY_LEN = ( STATIC.W3D_NAME_LEN * 2 )

        -- "Flags used in the W3dAggregateMiscInfo structure"
        STATIC.W3D_AGGREGATE_FORCE_SUB_OBJ_LOD = 0x00000001

        --- @class W3dAggregateHeaderStruct
        --- @field Version integer
        --- @field Name string
        deserializeLib.RegisterComplexDataType( "W3dAggregateHeaderStruct", {
            { Name = "Version", Type = fundamentalDataTypeEnum.UInt32 },
            { Name = "Name",  Type = fundamentalDataTypeEnum.String, Size = STATIC.W3D_NAME_LEN },
        } )

        --- @class W3dAggregateInfoStruct
        --- @field BaseModelName string
        --- @field SubObjectCount integer
        deserializeLib.RegisterComplexDataType( "W3dAggregateInfoStruct", {
            { Name = "BaseModelName",  Type = fundamentalDataTypeEnum.String, Size = ( STATIC.W3D_NAME_LEN * 2 ) },
            { Name = "SubObjectCount", Type = fundamentalDataTypeEnum.UInt32 },
        } )

        --- @class W3dAggregateSubObjectStruct
        --- @field SubObjectName string
        --- @field BoneName string
        deserializeLib.RegisterComplexDataType( "W3dAggregateSubObjectStruct", {
            { Name = "SubObjectName", Type = fundamentalDataTypeEnum.String, Size = ( STATIC.W3D_NAME_LEN * 2 ) },
            { Name = "BoneName",      Type = fundamentalDataTypeEnum.String, Size = ( STATIC.W3D_NAME_LEN * 2 ) },
        } )

        --- "Structures for version 1.1 and newer"

        --- @class W3dTextureReplacerHeaderStruct
        --- @field ReplacedTexturesCount integer
        deserializeLib.RegisterComplexDataType( "W3dTextureReplacerHeaderStruct", {
            { Name = "ReplacedTexturesCount", Type = fundamentalDataTypeEnum.UInt32 },
        } )

        --- @class W3dTextureReplacerStruct
        --- @field MeshPath string[]
        --- @field BonePath string[]
        --- @field OldTextureName string
        --- @field NewTextureName string
        --- @field TextureParameters W3dTextureInfoStruct
        deserializeLib.RegisterComplexDataType( "W3dTextureReplacerStruct", {
            { Name = "MeshPath",        Type = fundamentalDataTypeEnum.String, ArrayLength = STATIC.MESH_PATH_ENTRIES, Size = STATIC.MESH_PATH_ENTRY_LEN },
            { Name = "BonePath",        Type = fundamentalDataTypeEnum.String, ArrayLength = STATIC.MESH_PATH_ENTRIES, Size = STATIC.MESH_PATH_ENTRY_LEN },
            { Name = "OldTextureName",  Type = fundamentalDataTypeEnum.String, Size = 260 },
            { Name = "NewTextureName",  Type = fundamentalDataTypeEnum.String, Size = 260 },
            { Name = "TextureParameters",  Type = "W3dTextureInfoStruct" },
        } )

        --- "Structures for version 1.2 asnd newer"

        --- @class W3dAggregateMiscInfo
        --- @field OriginalClassId integer
        --- @field Flags integer
        --- @field Reserved integer[]
        deserializeLib.RegisterComplexDataType( "W3dAggregateMiscInfo", {
            { Name = "OriginalClassId", Type = fundamentalDataTypeEnum.UInt32 },
            { Name = "Flags",           Type = fundamentalDataTypeEnum.UInt32 },
            { Name = "Reserved",        Type = fundamentalDataTypeEnum.UInt32, ArrayLength = 3 },
        } )
    end
end