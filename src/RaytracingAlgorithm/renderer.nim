import world
import material
import color
import rayhit
import pcg
import geometry
import stats
from utils import injectProcName
from ray import Ray
from exception import NotImplementedError, AbstractMethodError
import std/[options, math, times, typetraits]

type
    Renderer* = ref object of RootObj # abstract class to solve rendering equation
        world*: World
        backgroundColor*: Color
        raysShot*: int

    DebugRenderer* = ref object of Renderer

    OnOffRenderer* = ref object of Renderer # useful for debugs
        color*: Color

    FlatRenderer* = ref object of Renderer # estimates the solution of the rendering equation by the light contribution.
                # uses the pigment of each surface to determine the final radiance

    PathTracer* = ref object of Renderer # path-tracing renderer
        pcg*: PCG
        numRays*: int
        maxRayDepth*: int
        russianRouletteLimit*: int # to reduce number of recursive calls

    PointlightRenderer* = ref object of Renderer # point light renderer
        ambientColor*: Color

        

# ----------- Constructors -----------
func newOnOffRenderer*(world: World, backgroundColor, color: Color): OnOffRenderer {.inline.}=
    ## constructor for OnOffRenderer
    return OnOffRenderer(world:world, backgroundColor:backgroundColor, color:color)

func newDebugRenderer*(world: World, backgroundColor: Color): DebugRenderer {.inline.}=
    ## constructor for DebugRenderer
    return DebugRenderer(world:world, backgroundColor: backgroundColor)

func newFlatRenderer*(world: World, backgroundColor: Color): FlatRenderer{.inline.}=
    ## constructor for FlatRenderer
    return FlatRenderer(world: world, backgroundColor: backgroundColor)

func newPathTracer*(world: World, backgroundColor: Color = Color.black(), pcg: PCG = newPCG(), numRays: int = 10, maxRayDepth: int = 2, russianRouletteLimit: int = 3): PathTracer {.inline.}=
    ## constructor for PathTracer (backgroundColor_default: black)
    return PathTracer(world: world, backgroundColor: backgroundColor, pcg: pcg, numRays: numRays, maxRayDepth: maxRayDepth, russianRouletteLimit: russianRouletteLimit)

func newPointlightRenderer*(world: World, backgroundColor: Color, ambientColor: Color): PointlightRenderer {.inline.}=
    ## constructor for PointlightRenderer
    return PointlightRenderer(world: world, backgroundColor: backgroundColor, ambientColor: ambientColor)

# ------------ Operators --------------
func `$`*(renderer: OnOffRenderer): string =
    return "OnOffRenderer"

func `$`*(renderer: DebugRenderer): string=
    return "DebugRenderer"

func `$`*(renderer: PathTracer): string=
    return "PathTracer"

func `$`*(renderer: FlatRenderer): string=
    return "FlatRenderer"

func `$`*(renderer: PointlightRenderer): string=
        return "PointlightRenderer"

# ----------- Methods -----------
method Get*(renderer: Renderer): (proc(r: Ray): Color) {.base, raises:[AbstractMethodError].}=
    ## abstract method
    raise AbstractMethodError.newException("Renderer.Get is an abstract method and cannot be called.")

method Get*(renderer: DebugRenderer): (proc(r: Ray): Color) =
    ## Returns the color of the renderer hit by ray
    ## Parameters
    ##      renderer (DebuRenderer)
    ## Returns
    ##      (Color): background color
    return proc(r: Ray): Color=
        return renderer.backgroundColor

method Get*(renderer: OnOffRenderer): (proc(r: Ray): Color) =
    ## Returns the color of the renderer hit by ray
    ## Parameters
    ##      renderer (OnOffRenderer)
    ## Returns
    ##      (Color): color (if there is intersection), background color (else)
    return proc(r: Ray): Color=
        let intersection = rayIntersect(renderer.world,r)
        if intersection.isSome:
            return renderer.color
        else:
            return renderer.backgroundColor

method Get*(renderer: FlatRenderer): (proc(r: Ray): Color) {.injectProcName.}=
    ## Returns the color of the renderer hit by ray
    ## Parameters
    ##      renderer (FlatRenderer)
    ## Returns
    ##      (Color): color computed from the BRDF and emitted radiance
    return proc(r: Ray): Color =
        #let start = now()
        var hit: Option[RayHit] = renderer.world.rayIntersect(r)
        if hit == none(RayHit):
            return renderer.backgroundColor
        let material = hit.get().material
        #echo hit.get().GetSurfacePoint()
        var
            brdfColor: Color = material.brdf.pigment.getColor(hit.get().GetSurfacePoint()) 
            emittedRadianceColor: Color = material.emitted_radiance.getColor(hit.get().GetSurfacePoint())
        ##let endTime = now() - start
        #mainStats.AddCall(procName, endTime)
        return ( brdfColor + emittedRadianceColor )


method Get*(renderer: PathTracer): (proc(ray: Ray): Color) {.gcsafe, injectProcName.} =
    ## Returns the color of the renderer hit by ray
    ## Parameters
    ##      renderer (PathTracer)
    ## Returns
    ##      (Color)
    return proc(ray: Ray): Color=
        #let start = now()
        if ray.depth > renderer.maxRayDepth:
            return Color.black()
        let hitrecord = renderer.world.rayIntersect(ray)
        if hitrecord == none(RayHit):
            return renderer.backgroundColor
        let hit = hitrecord.get()
        var hit_color: Color = hit.material.brdf.pigment.getColor(hit.GetSurfacePoint())
        let
            emitted_radiance = hit.material.emitted_radiance.getColor(hit.GetSurfacePoint())
            hit_color_lum = max(hit_color.r, max(hit_color.g, hit_color.b))
        # Russian roulette
        if ray.depth >= renderer.russianRouletteLimit:
            let q = max(0.05, 1 - hit_color_lum)
            if renderer.pcg.random_float() > q:
                #hit_color = hit_color * (1.0 / (1 - hit_color_lum))
                hit_color = hit_color * (1.0 / (1 - q))
            else:
                return emitted_radiance
        # Monte Carlo integration
        var cum_radiance: Color = Color.black()
        if hit_color_lum > 0.0:
            #countup(0, renderer.numRays)
            for ray_index in 0 || renderer.numRays:
                let newRay = hit.material.brdf.ScatterRay(
                    renderer.pcg,
                    hit.ray.dir,
                    hit.world_point,
                    hit.normal,
                    ray.depth + 1
                )
                let newRadiance = renderer.Get()(newRay)
                cum_radiance = cum_radiance + hit_color * newRadiance
                renderer.raysShot  = renderer.raysShot + 1
        #let endTime = now() - start
        #mainStats.AddCall(procName, endTime, 1)
        return emitted_radiance + cum_radiance * (1.0 / float32(renderer.numRays))

method Get*(self: PointlightRenderer): (proc(ray: Ray): Color) {.injectProcName.}=
    ## Returns the color of the renderer hit by ray
    ## Parameters
    ##      renderer (PointlightRenderer)
    ## Returns
    ##      (Color)
    return proc(ray: Ray): Color=
        #let start = now()
        let hit = self.world.rayIntersect(ray)
        if not hit.isSome:
            return self.backgroundColor
        
        let hitrecord = hit.get()
        let hitmaterial = hitrecord.material
        var result_color: Color = self.ambientColor
        for light in self.world.pointLights:
            if self.world.IsPointVisible(light.position, hitrecord.world_point):
                let
                    distance_vec = (hitrecord.world_point - light.position).convert(Vector3)
                    distance = distance_vec.norm()
                    in_dir = distance_vec * (1.0 / distance)
                    costheta = max(0.0, -Dot(ray.dir.normalize(), hitrecord.normal.normalize()))
                var distance_factor: float32
                if light.linearRadius > 0.0:
                    distance_factor = pow((light.linearRadius / distance), 2.0) 
                else:
                    distance_factor = 1.0
                let
                    emitted_color = hitmaterial.emitted_radiance.getColor(hitrecord.GetSurfacePoint())
                    brdf_color = hitmaterial.brdf.eval(
                        hitrecord.normal,
                        in_dir,
                        ray.dir,
                        hitrecord.GetSurfacePoint()
                    )
                #echo emitted_color, " - ",brdf_color, " -- ",light.color, " - ",costheta, " - ",distance_factor
                result_color = result_color + (emitted_color + brdf_color) * light.color * costheta * distance_factor
        ##let endTime = now() - start
        #mainStats.AddCall(procName, endTime, 1)
        return result_color