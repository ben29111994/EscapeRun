using UnityEngine;
using System.Collections.Generic;
using System.Linq;
using System.Threading;

[System.Serializable]
public class DeformChunk
{
    //list of indexes to m_currentVertices
    public List<int> vertexIndexes = new List<int>();

    // the bound sof the chunk used for center, position and intersects
    public Bounds chunkBounds;

    //List of indexes to m_deformaingMesh.triangles (which in turn is a list of indexes to m_deformingMesh.vertices)
    //public List<int> chunkTriangles = new List<int>();
    //public MeshCollider chunkCollider;
}

public class MeshDeformer : MonoBehaviour
{
    [SerializeField,
     Tooltip(
         "This will cause an unseen delay before deformations can take place but will allow the main thread to run")]
    private bool UsePreCalulatedThreading = false;

    [SerializeField,
     Tooltip("(EXPEREMENTAL) Reduced runtime cost of deformation (currently causes some undesirable results of missing deformations)")]
    private bool UseRuntimeThreading = false;

    [SerializeField, Tooltip("Game objects that will not cause deformation")] List<GameObject> ignoreObjects = new List<GameObject>();

    [Space]
    [SerializeField, Tooltip("Number of chunks on each axis (A value of 2 generates 8 chunks)")] private int minChunksCubed = 2;
    [SerializeField, Tooltip("The maximum vertices per chunk, overpopulated chunks will be split in half")] private int maxVertsPerChunk = 100;

    List<DeformChunk> deformChunks = new List<DeformChunk> ();

    Mesh baseMesh;
    Mesh deformingMesh;
    List<Vector3> currentVertices = new List<Vector3>();

    [Space]
    [SerializeField, Tooltip("X = minimum velocity to cause a deformation \nY = maximum clamp for collision velocity")] Vector2 minMaxCollisionVelocity = new Vector2(15, 50);
    [SerializeField, Tooltip("A range which the collision velocity will be scaled to")] Vector2 minMaxDeformationRange = new Vector2(0, 5);
    float deformationClampValue = float.MaxValue;
    bool changedMesh = false;

    [SerializeField] private bool limitDeformationToChunks;

    //[SerializeField] private bool affectMeshCollider = false;
    //private MeshCollider meshCollider;

    //[SerializeField] private bool addVerts = false;

    float startTimer = 0.1f;

    Thread preThread;
    Thread thread;

    [SerializeField, Tooltip("If populated, this mesh will be used instead of the attached mesh filter to this class")]
    private MeshFilter overrideMeshFilter;
    private MeshCollider meshC;

    void Start()
	{
        meshC = GetComponent<MeshCollider>();


        if (overrideMeshFilter == null)
	        overrideMeshFilter = GetComponent<MeshFilter>();

        overrideMeshFilter.mesh = meshC.sharedMesh;
	    if (overrideMeshFilter == null)
	    {
	        Debug.LogError("MeshDeformer has no MeshFilter so will not perform deformations.");
            Destroy(this);
	        return;
	    }

	    baseMesh = overrideMeshFilter.sharedMesh;
	    deformingMesh = overrideMeshFilter.mesh;
	    currentVertices = deformingMesh.vertices.ToList();

	    Bounds bounds = baseMesh.bounds;
	    if (UsePreCalulatedThreading)
	    {
	        preThread = new Thread(() => ChunkSetUp(bounds));
	        preThread.Start();
	    }
        else
	        ChunkSetUp(bounds);

        //if (affectMeshCollider)
        //{
        //    foreach (DeformChunk chunk in deformChunks)
        //        //Attempt at split up convex mesh colliders
        //    {
        //        chunk.chunkCollider = gameObject.AddComponent<MeshCollider>();
        //        chunk.chunkCollider.inflateMesh = true;
        //        chunk.chunkCollider.skinWidth = 0.1f;
        //        chunk.chunkCollider.convex = true;

        //        List<Vector3> vertsPositions = new List<Vector3>();
        //        foreach (int vertIndex in chunk.vertexIndexes)
        //            vertsPositions.Add(currentVertices[vertIndex]);

        //        Mesh colMesh = GenerateChunkCollider(vertsPositions);

        //        if(colMesh == null)
        //            Destroy(chunk.chunkCollider);
        //        else
        //            chunk.chunkCollider.sharedMesh = colMesh; 
        //    }

        //    meshCollider = GetComponent<MeshCollider>();

        //    if (meshCollider == null)
        //    {
        //        meshCollider = gameObject.AddComponent<MeshCollider>();
        //        meshCollider.convex = true;
        //    }

        //    meshCollider.sharedMesh = m_deformingMesh;
        //}

        // Rescale deform clamp
        deformationClampValue = Mathf.Clamp(deformationClampValue, minMaxCollisionVelocity.x, minMaxCollisionVelocity.y);
        deformationClampValue = RemapFloat(deformationClampValue, minMaxCollisionVelocity.x, minMaxCollisionVelocity.y, minMaxDeformationRange.x, minMaxDeformationRange.y);
    }

    //Mesh GenerateChunkCollider(List<Vector3> _vertPositions)
    //{
    //    if (_vertPositions.Count < 10)
    //        return null;

    //    var calc = new ConvexHullCalculator();
    //    var verts = new List<Vector3>();
    //    var tris = new List<int>();
    //    var normals = new List<Vector3>();
    //    var points = _vertPositions;
    //    var mesh = new Mesh();

    //    calc.GenerateHull(points, true, ref verts, ref tris, ref normals);

    //    mesh.Clear();
    //    mesh.SetVertices(verts);
    //    mesh.SetTriangles(tris, 0);
    //    mesh.SetNormals(normals);

    //    return mesh;
    //}

    void ChunkSetUp(Bounds meshBounds)
	{
	    if (minChunksCubed > 1)
	    {
            // Prep for bounds
            //Bounds meshBounds = baseMesh.bounds;
	        meshBounds.size *= 1.01f; // increase size to ensure we include all verts

            Vector3 chunkSize = meshBounds.size / minChunksCubed;
	        Vector3 chunkStartPos = meshBounds.center + (meshBounds.size / 2) - (chunkSize/2);

            Vector3 curChunkPos = chunkStartPos;
            Bounds curBounds = new Bounds(curChunkPos, chunkSize);

            // populate minimum number of chunks

            List<int> availableVertIndexes = new List<int>();

            for (int i = 0; i < currentVertices.Count; i++)
                availableVertIndexes.Add(i);

            for (int i_x = 0; i_x < minChunksCubed; i_x++)
	        {
	            for (int i_y = 0; i_y < minChunksCubed; i_y++)
	            {
	                for (int i_z = 0; i_z < minChunksCubed; i_z++)
	                {
	                    curBounds.center = curChunkPos;

                        DeformChunk newChunk = new DeformChunk();
                        newChunk.chunkBounds = new Bounds(curChunkPos, curBounds.size);

                        bool chunkUsed = false;

                        for (int vertIndex = 0; vertIndex < availableVertIndexes.Count; vertIndex++)
                        {
                            if (curBounds.Contains(currentVertices[availableVertIndexes[vertIndex]]))
                            {
                                newChunk.vertexIndexes.Add(availableVertIndexes[vertIndex]);
                                chunkUsed = true;
                            }
                        }

                        if (chunkUsed)
                        {
                            deformChunks.Add(newChunk);

                            for (int usedIndex = 0; usedIndex < newChunk.vertexIndexes.Count; usedIndex++)
                                availableVertIndexes.Remove(newChunk.vertexIndexes[usedIndex]);
                        }

                        curChunkPos -= new Vector3(0,0,chunkSize.z);
                    }
	                curChunkPos -= new Vector3(0, chunkSize.y, -(chunkSize.z * minChunksCubed));
                }
	            curChunkPos -= new Vector3(chunkSize.x, -(chunkSize.y * minChunksCubed), 0);
            }

            List<DeformChunk> newSplitChunks = new List<DeformChunk>();
            List<DeformChunk> oldChunksToRemove = new List<DeformChunk>();
            // check for overpopulated chunks
            foreach (DeformChunk chunk in deformChunks)
	        {
	            if (chunk.vertexIndexes.Count <= maxVertsPerChunk)
	                continue;

                oldChunksToRemove.Add(chunk);
                newSplitChunks.AddRange(SplitChunk(chunk));
            }

	        foreach (DeformChunk chunk in oldChunksToRemove)
	            deformChunks.Remove(chunk);

            deformChunks.AddRange(newSplitChunks);

            // Generate triangle lists for adding verts/collision meshes
            //if (addVerts)
            //{
            //       int firstInTri = 0;

            //       for (int triangleIndex = 0; triangleIndex < m_deformingMesh.triangles.Length; triangleIndex++)
            //       {
            //           for (int chunkIndex = 0; chunkIndex < deformChunks.Count; chunkIndex++)
            //           {
            //               for (int chunkVertIndexIndex = 0;
            //                   chunkVertIndexIndex < deformChunks[chunkIndex].vertexIndexes.Count;
            //                   chunkVertIndexIndex++)
            //               {
            //                   if (m_deformingMesh.triangles[triangleIndex] ==
            //                       deformChunks[chunkIndex].vertexIndexes[chunkVertIndexIndex])
            //                   {
            //                       firstInTri = triangleIndex - (triangleIndex % 3);

            //                       // add the triangle to the chunks triangle list
            //                       deformChunks[chunkIndex].chunkTriangles.Add(firstInTri);
            //                       deformChunks[chunkIndex].chunkTriangles.Add(firstInTri + 1);
            //                       deformChunks[chunkIndex].chunkTriangles.Add(firstInTri + 2);
            //                   }
            //               }
            //           }
            //       }
            //   }
        }
        else
        {
            // Chunks will not be used
            DeformChunk newChunk = new DeformChunk();
            newChunk.chunkBounds = baseMesh.bounds;

            for (int vertIndex = 0; vertIndex < currentVertices.Count; vertIndex++)
                newChunk.vertexIndexes.Add(vertIndex);

            deformChunks.Add(newChunk);
        }
    }

    List<DeformChunk> SplitChunk(DeformChunk _chunkToSplit)
    {
        List<DeformChunk> newChunks = new List<DeformChunk>();
        // Find the axis to split the chunk along.
        float largestAxis = -1f;
        int largestAxisIndex = 1;
        for (int i = 0; i < 3; i++)
        {
            if (Mathf.Abs(_chunkToSplit.chunkBounds.size[i]) > largestAxis)
            {
                largestAxisIndex = i;
                largestAxis = _chunkToSplit.chunkBounds.size[i];
            }
        }

        Vector3 tempSize = _chunkToSplit.chunkBounds.size;
        tempSize[largestAxisIndex] = largestAxis / 1.8f;

        Vector3 tempPos = _chunkToSplit.chunkBounds.center;
        tempPos[largestAxisIndex] = tempPos[largestAxisIndex] + largestAxis / 4;

        DeformChunk newChunk1 = new DeformChunk();
        newChunk1.chunkBounds = new Bounds(tempPos, tempSize);
        newChunks.Add(newChunk1);

        DeformChunk newChunk2 = new DeformChunk();
        newChunk2.chunkBounds = new Bounds(tempPos,tempSize);
        tempPos[largestAxisIndex] = tempPos[largestAxisIndex] - largestAxis / 2;
        newChunk2.chunkBounds.center = tempPos;
        newChunks.Add(newChunk2);

        foreach (int vertIndex in _chunkToSplit.vertexIndexes)
        {
            if(newChunk1.chunkBounds.Contains(currentVertices[vertIndex]))
                newChunks[0].vertexIndexes.Add(vertIndex);
            else
                newChunks[1].vertexIndexes.Add(vertIndex);
        }

        bool removeChunk1 = false;
        bool removeChunk2 = false;

        if (newChunks[0].vertexIndexes.Count > maxVertsPerChunk)
        {
            newChunks.AddRange(SplitChunk(newChunks[0]));
            removeChunk1 = true;
        }

        if (newChunks[1].vertexIndexes.Count > maxVertsPerChunk)
        {
            newChunks.AddRange(SplitChunk(newChunks[1]));
            removeChunk2 = true;
        }

        if(removeChunk1)
            newChunks.Remove(newChunk1);
        if (removeChunk2)
            newChunks.Remove(newChunk2);

        List<DeformChunk> emptyChunks = new List<DeformChunk>();
        foreach (DeformChunk chunk in newChunks)
        {
            if(chunk.vertexIndexes.Count == 0)
                emptyChunks.Add(chunk);
        }

        foreach (DeformChunk chunk in emptyChunks)
            newChunks.Remove(chunk);

        return newChunks;
    }

    void ClearChunks()
    {
        deformChunks.Clear();
    }

	void Update()
	{
        if (startTimer <= 0)
        {
            if (deformingMesh != null && changedMesh)
            {
                deformingMesh.vertices = currentVertices.ToArray();
                deformingMesh.RecalculateNormals();

                //if (affectMeshCollider)
                //{
                //    UpdateMeshColliders();
                //    //meshCollider.sharedMesh = m_deformingMesh;
                //}

                changedMesh = false;
            }
        }
        else
            startTimer -= Time.deltaTime;
    }


    //void UpdateMeshColliders()
    //{
    //    foreach (DeformChunk chunk in deformChunks)
    //    {
    //        if (chunk.chunkCollider == null || chunk.vertexIndexes.Count < 4)
    //            continue;

    //        List<Vector3> vertsPositions = new List<Vector3>();
    //        foreach (int vertIndex in chunk.vertexIndexes)
    //            vertsPositions.Add(currentVertices[vertIndex]);


    //        var calc = new ConvexHullCalculator();
    //        var verts = new List<Vector3>();
    //        var tris = new List<int>();
    //        var normals = new List<Vector3>();
    //        var points = vertsPositions;

    //        calc.GenerateHull(points, true, ref verts, ref tris, ref normals);

    //        Mesh newMesh = new Mesh();

    //        newMesh.Clear();
    //        newMesh.SetVertices(verts);
    //        newMesh.SetTriangles(tris, 0);
    //        newMesh.SetNormals(normals);

    //        chunk.chunkCollider.sharedMesh = newMesh;
    //    }
    //}

    public void DeformMesh(Vector3 _deformPoint, Vector3 _relativeVelocity)
    {
        _relativeVelocity = Vector3.ClampMagnitude(_relativeVelocity, minMaxCollisionVelocity.y);
        _relativeVelocity = RemapVector3(_relativeVelocity, minMaxCollisionVelocity.x, minMaxCollisionVelocity.y, minMaxDeformationRange.x, minMaxDeformationRange.y);
        _relativeVelocity = overrideMeshFilter.transform.InverseTransformVector(_relativeVelocity);

        _deformPoint = overrideMeshFilter.transform.InverseTransformPoint(_deformPoint);

        List<int> inRangeChunkIndexes = new List<int>();

        Bounds impactBounds = new Bounds(_deformPoint,
            new Vector3(_relativeVelocity.magnitude, _relativeVelocity.magnitude, _relativeVelocity.magnitude) * 2.1f);

        for (int i = 0; i < deformChunks.Count; i++)
        {
            if (impactBounds.Intersects(deformChunks[i].chunkBounds))
                inRangeChunkIndexes.Add(i);
        }

        // Check if we are required to add new vertices
        //if (addVerts)
        //{
        //    FindNewVertPosition(_deformPoint, _relativeVelocity, inRangeChunkIndexes);
        //}

        if(minChunksCubed <= 1 && inRangeChunkIndexes.Count <= 0)
            inRangeChunkIndexes.Add(0);

        if (UseRuntimeThreading)
        {
            thread = new Thread(() => DoDeformationOnThread(inRangeChunkIndexes, _deformPoint, _relativeVelocity));
            thread.Start();
        }
        else
        {
            DoDeformationOnThread(inRangeChunkIndexes, _deformPoint, _relativeVelocity);
        }
    }

    void DoDeformationOnThread(List<int> inRangeChunkIndexes, Vector3 _deformPoint, Vector3 _relativeVelocity)
    {
        foreach (int index in inRangeChunkIndexes)
        {
            foreach (int vertindex in deformChunks[index].vertexIndexes)
            {
                if (Vector3.Distance(_deformPoint, currentVertices[vertindex]) >= _relativeVelocity.magnitude)
                    continue;

                Vector3 changeValue = _relativeVelocity - (_relativeVelocity * Vector3.Distance(_deformPoint, currentVertices[vertindex]) / _relativeVelocity.magnitude);
                changeValue = Vector3.ClampMagnitude(changeValue, deformationClampValue);

                if (limitDeformationToChunks)
                {
                    changeValue = deformChunks[index].chunkBounds.ClosestPoint(currentVertices[vertindex] + changeValue) - currentVertices[vertindex];
                }

                currentVertices[vertindex] += changeValue;
            }

            changedMesh = true;
        }
    }

    #region Find point on nearest triangle
    /*
    // find affected chunks and loop through their verts triangles to find nearest intersecting triangle

    void FindNewVertPosition(Vector3 _deformPoint, Vector3 _relativeVelocity, List<int> _inRangeChunkIndexes)
    {
        if (_inRangeChunkIndexes.Count == 0)
            return;

        int closestChunkIndex = -1;
        int closestChunkTriangleIndex0 = -1;
        float shortestDistance = Mathf.Infinity;

        // set the ray back a unit to in case of surface deform points
        Ray deformRay = new Ray(_deformPoint - _relativeVelocity.normalized, _relativeVelocity.normalized);

        for(int chunkIndex = 0; chunkIndex < _inRangeChunkIndexes.Count; chunkIndex++)
        {
            for(int chunkTriangleIndex = 0; chunkTriangleIndex < deformChunks[_inRangeChunkIndexes[chunkIndex]].chunkTriangles.Count; chunkTriangleIndex+=3)
            {
                // look for a point on the surface of the render mesh
                float rayLength = IntersectRayTriangle(deformRay,
                    currentVertices[m_deformingMesh.triangles[deformChunks[_inRangeChunkIndexes[chunkIndex]].chunkTriangles[chunkTriangleIndex]]],
                    currentVertices[m_deformingMesh.triangles[deformChunks[_inRangeChunkIndexes[chunkIndex]].chunkTriangles[chunkTriangleIndex + 1]]],
                    currentVertices[m_deformingMesh.triangles[deformChunks[_inRangeChunkIndexes[chunkIndex]].chunkTriangles[chunkTriangleIndex + 2]]]);

                if (rayLength != float.NaN && rayLength < shortestDistance)
                {
                    closestChunkIndex = chunkIndex;
                    closestChunkTriangleIndex0 = chunkTriangleIndex;
                    shortestDistance = rayLength;
                }
            }
        }

        if (shortestDistance != Mathf.Infinity)
        {
            // shorten the ray to undo the surface deform change
            shortestDistance -= 1;
            GameObject sphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            sphere.transform.position = _deformPoint + (_relativeVelocity.normalized * shortestDistance);
            sphere.transform.position = transform.TransformPoint(sphere.transform.position);

            // gather all chunks which share this triangle
            List<int> chunkWithTriangleIndexes = new List<int>();
            chunkWithTriangleIndexes.Add(_inRangeChunkIndexes[closestChunkIndex]);

            for (int chunkIndex = 0; chunkIndex < deformChunks.Count; chunkIndex++)
            {
                if (chunkIndex == _inRangeChunkIndexes[closestChunkIndex])
                    continue;

                for (int chunkTriangleIndex = 0; chunkTriangleIndex < deformChunks[chunkIndex].chunkTriangles.Count; chunkTriangleIndex += 3)
                {
                    if (deformChunks[chunkIndex].chunkTriangles[chunkTriangleIndex] ==
                        deformChunks[_inRangeChunkIndexes[closestChunkIndex]].chunkTriangles[closestChunkTriangleIndex0])
                    {
                        // Add chunk to the list used to add the new triangles
                        chunkWithTriangleIndexes.Add(chunkIndex);

                        // Remove old triangle from this chunk
                        deformChunks[chunkIndex].chunkTriangles.RemoveAt(chunkTriangleIndex);
                        deformChunks[chunkIndex].chunkTriangles.RemoveAt(chunkTriangleIndex);
                        deformChunks[chunkIndex].chunkTriangles.RemoveAt(chunkTriangleIndex);
                        break;
                    }
                }
            }

            // Add new vert to vertex list
            Vector3 newVertex = _deformPoint + (_relativeVelocity.normalized * shortestDistance);
            currentVertices.Add(newVertex);

            int firstIndexInClosestTri = deformChunks[_inRangeChunkIndexes[closestChunkIndex]].chunkTriangles[closestChunkTriangleIndex0];

            // Now add a vert to the point on the surface
            List<int> triangles = m_deformingMesh.triangles.ToList();

            triangles.Add(currentVertices.Count - 1);
            triangles.Add(m_deformingMesh.triangles[firstIndexInClosestTri + 1]);
            triangles.Add(m_deformingMesh.triangles[firstIndexInClosestTri + 2]);

            triangles.Add(m_deformingMesh.triangles[firstIndexInClosestTri]);
            triangles.Add(currentVertices.Count - 1);
            triangles.Add(m_deformingMesh.triangles[firstIndexInClosestTri + 2]);

            triangles.Add(m_deformingMesh.triangles[firstIndexInClosestTri]);
            triangles.Add(m_deformingMesh.triangles[firstIndexInClosestTri + 1]);
            triangles.Add(currentVertices.Count - 1);

            triangles.RemoveAt(firstIndexInClosestTri);
            triangles.RemoveAt(firstIndexInClosestTri);
            triangles.RemoveAt(firstIndexInClosestTri);

            m_deformingMesh.SetVertices(currentVertices);
            m_deformingMesh.SetTriangles(triangles, 0);
            m_deformingMesh.RecalculateNormals();

            //remove triangle from closest (reference) chunk
            deformChunks[_inRangeChunkIndexes[closestChunkIndex]].chunkTriangles.RemoveAt(closestChunkTriangleIndex0);
            deformChunks[_inRangeChunkIndexes[closestChunkIndex]].chunkTriangles.RemoveAt(closestChunkTriangleIndex0);
            deformChunks[_inRangeChunkIndexes[closestChunkIndex]].chunkTriangles.RemoveAt(closestChunkTriangleIndex0);

            // Add new triangles to all affected chunks
            for (int chunkIndex = 0; chunkIndex < chunkWithTriangleIndexes.Count; chunkIndex++)
            {
                for (int triIndex = triangles.Count - 9; triIndex < triangles.Count; triIndex++)
                {
                    deformChunks[chunkIndex].chunkTriangles.Add(triIndex);
                }
            }

            // add the new vert to closest chunk
            deformChunks[_inRangeChunkIndexes[closestChunkIndex]].vertexIndexes.Add(currentVertices.Count - 1);
        }
        else
        {
            Debug.Log("no point found");
        }
    }

    const float kEpsilon = 0.000001f;
    /// <summary>
    /// Ray-versus-triangle intersection test suitable for ray-tracing etc.
    /// Port of Möller–Trumbore algorithm c++ version from:
    /// https://en.wikipedia.org/wiki/Möller–Trumbore_intersection_algorithm
    /// </summary>
    /// <returns><c>The distance along the ray to the intersection</c> if one exists, <c>NaN</c> if one does not.</returns>
    /// <param name="ray">Le ray.</param>
    /// <param name="v0">A vertex of the triangle.</param>
    /// <param name="v1">A vertex of the triangle.</param>
    /// <param name="v2">A vertex of the triangle.</param>
    public static float IntersectRayTriangle(Ray ray, Vector3 v0, Vector3 v1, Vector3 v2)
    {
        // edges from v1 & v2 to v0.     
        Vector3 e1 = v1 - v0;
        Vector3 e2 = v2 - v0;

        Vector3 h = Vector3.Cross(ray.direction, e2);
        float a = Vector3.Dot(e1, h);
        if ((a > -kEpsilon) && (a < kEpsilon))
        {
            return float.NaN;
        }

        float f = 1.0f / a;

        Vector3 s = ray.origin - v0;
        float u = f * Vector3.Dot(s, h);
        if ((u < 0.0f) || (u > 1.0f))
        {
            return float.NaN;
        }

        Vector3 q = Vector3.Cross(s, e1);
        float v = f * Vector3.Dot(ray.direction, q);
        if ((v < 0.0f) || (u + v > 1.0f))
        {
            return float.NaN;
        }

        float t = f * Vector3.Dot(e2, q);
        if (t > kEpsilon)
        {
            return t;
        }
        else
        {
            return float.NaN;
        }
    }

*/
    #endregion

    void OnCollisionEnter(Collision col)
    {
        if (startTimer <= 0)
        {
            // ignore collision if it isn't violent enough or we have no chunks
            if (col.relativeVelocity.magnitude < minMaxCollisionVelocity.x || deformChunks.Count == 0)
                return;

            if (col.gameObject == gameObject)
                return;

            // also ignore collision if it is with one of our ignore objects
            foreach (GameObject ignoreObject in ignoreObjects)
            {
                if (col.gameObject == ignoreObject)
                    return;

                foreach (ContactPoint Contact in col.contacts)
                {
                    if (Contact.thisCollider.gameObject == ignoreObject)
                        return;
                }
            }

            foreach (ContactPoint Contact in col.contacts)
            {
                DeformMesh(Contact.point, col.relativeVelocity);
            }
        }
	}
	
	public void resetDeformation()
	{
        if (baseMesh != null)
        {
            // need new chunk calculations
            deformChunks.Clear();

            // make a new mesh and set its vertices and sumbeshes (for materials) to match
            Mesh newMesh = new Mesh();

            newMesh.vertices = baseMesh.vertices;
            newMesh.subMeshCount = baseMesh.subMeshCount;

            // this is needed to match the triangles that relate to each submesh's materials
            for (int subMeshIndex = 0; subMeshIndex < newMesh.subMeshCount; subMeshIndex++)
            {
                newMesh.SetTriangles(baseMesh.GetTriangles(subMeshIndex), subMeshIndex);
            }
            // this makes the lighting work immediately
            newMesh.RecalculateNormals();

            // set up just like on start
            GetComponent<MeshFilter>().mesh = newMesh;

            deformingMesh = GetComponent<MeshFilter>().mesh;

            currentVertices = deformingMesh.vertices.ToList();
            //ChunkSetUp();
        }
	}


    #region Utility

    public static Vector3 RemapVector3(Vector3 value, float fromMagnitude1, float toMagnitude1, float fromMagnitude2, float toMagnitude2)
    {
        Vector3 from1 = value.normalized * fromMagnitude1;
        Vector3 to1 = value.normalized * toMagnitude1;
        Vector3 from2 = value.normalized * fromMagnitude2;
        Vector3 to2 = value.normalized * toMagnitude2;

        Vector3 fromAbs = value - from1;
        Vector3 fromMaxAbs = to1 - from1;

        Vector3 normal = new Vector3(fromAbs.x / fromMaxAbs.x, fromAbs.y / fromMaxAbs.y, fromAbs.z / fromMaxAbs.z);

        if(float.IsNaN(normal.x))
            normal = new Vector3(0, normal.y, normal.z);
        if (float.IsNaN(normal.y))
            normal = new Vector3(normal.x, 0, normal.z);
        if (float.IsNaN(normal.z))
            normal = new Vector3(normal.x, normal.y, 0);

        Vector3 toMaxAbs = to2 - from2;
        Vector3 toAbs = new Vector3(toMaxAbs.x * normal.x, toMaxAbs.y * normal.y, toMaxAbs.z * normal.z);
        Vector3 result = toAbs + from2;

        return result;
    }

    public static float RemapFloat(float value, float from1, float to1, float from2, float to2)
    {
        return from2 + (value - from1) * (to2 - from2) / (to1 - from1);
    }

    #endregion

    #region Gizmos

    public enum MG_GizmoType
    {
        None,
        Bounds,
        Chunk
    }
    public class MG_GizmoCube
    {
        public Vector3 m_pos;
        public Vector3 m_size;
        public MG_GizmoType m_gizType;

        public MG_GizmoCube(Vector3 _pos, Vector3 _size, MG_GizmoType _type)
        {
            m_pos = _pos;
            m_size = _size;
            m_gizType = _type;
        }
    }

    List<MG_GizmoCube> gizmoCubes = new List<MG_GizmoCube>();

    List<Vector3> gizmoSpheres = new List<Vector3>();

    int specificChunk = -1;

    void OnDrawGizmosSelected()
    {
        if (specificChunk == -1)
        {
            foreach (MG_GizmoCube giz in gizmoCubes)
            {
                Gizmos.color = GetGizmoColour(giz.m_gizType);
                Gizmos.DrawCube(giz.m_pos, giz.m_size);
            }
        }
        else if(specificChunk < deformChunks.Count)
        {
            Gizmos.color = GetGizmoColour(MG_GizmoType.Bounds);
            Gizmos.DrawCube(deformChunks[specificChunk].chunkBounds.center, deformChunks[specificChunk].chunkBounds.size);

            Gizmos.color = GetGizmoColour(MG_GizmoType.Chunk);

            foreach (int index in deformChunks[specificChunk].vertexIndexes)
            {
                Gizmos.DrawSphere(currentVertices[index], 0.01f);
            }
        }

        Gizmos.color = GetGizmoColour(MG_GizmoType.Chunk);

        foreach (Vector3 pos in gizmoSpheres)
        {
            Gizmos.DrawSphere(pos, 0.01f);
        }
    }


    Color GetGizmoColour(MG_GizmoType _colour)
    {
        switch (_colour)
        {
            case MG_GizmoType.Bounds:
                return Color.yellow - new Color(0, 0, 0, 0.5f);
            case MG_GizmoType.Chunk:
                return Color.cyan - new Color(0, 0, 0, 0.5f);
            default:
                return Color.white - new Color(0, 0, 0, 0.5f);
        }
    }

    #endregion
}
