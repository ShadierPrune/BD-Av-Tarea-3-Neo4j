// Parte 1
// 1. Visualización e interpretación del grafo 

MATCH p=()-[]->() RETURN p

// 2. Casa con más visitas

MATCH (c:Casa)
RETURN  c.id, c.direccion, COUNT {
(:Estudiante)-[:PIDIO_DULCES]->(c:Casa)
} AS cant_visitas
ORDER BY cant_visitas DESC LIMIT 10;

// 3. Estudiante con más dulces 

MATCH (e:Estudiante)-[r:PIDIO_DULCES]->(:Casa)
RETURN e.id, COUNT(r) AS cant_visitas, SUM(r.cantidad) AS cant_dulces
ORDER BY cant_dulces DESC LIMIT 15;

// 4. Visitas sin dulces

// 4.1 Query visitas sin dulces

MATCH (e:Estudiante)-[r:PIDIO_DULCES]->(c:Casa)
WHERE r.cantidad = 0
RETURN e.id, c.direccion, r.tipo;

// 4.2 Obteniendo la cantidad de visitas sin dulces y porcentaje con relación a todas las visitas

MATCH (:Estudiante)-[r:PIDIO_DULCES]->(:Casa)
WITH count(r) AS total // guarda el total de visitas

MATCH (:Estudiante)-[r:PIDIO_DULCES]->(:Casa)
WHERE r.cantidad = 0 
WITH count(r) AS cant_visitas_sin_dulces, total //guarda las visitas sin dulces

RETURN cant_visitas_sin_dulces,100*(cant_visitas_sin_dulces)/(total) AS Porcentaje;

// Parte 2
// 1. Proteccion de grafos
// 1.1 Proyeccion de grafo (normal)

CALL gds.graph.project(
'halloween',
['Estudiante', 'Casa'],
{PIDIO_DULCES: {orientation: 'NATURAL'}}
)
YIELD graphName, nodeCount, relationshipCount
RETURN graphName, nodeCount, relationshipCount;

// 1.2 Proyeccion de grafo, pero con otra orientación

CALL gds.graph.project(
'halloween2',
['Estudiante', 'Casa'],
{PIDIO_DULCES: {orientation: 'UNDIRECTED'}}
)
YIELD graphName, nodeCount, relationshipCount
RETURN graphName, nodeCount, relationshipCount;

// 1.3 Proyeccion al reves
CALL gds.graph.project(
'halloween3',
['Estudiante', 'Casa'],
{PIDIO_DULCES: {orientation: 'REVERSE'}}
)
YIELD graphName, nodeCount, relationshipCount
RETURN graphName, nodeCount, relationshipCount;

// 1.4 Borrar proyecciones
// 1.4.1 (no necesario) Borrar la primera proyeccion
CALL gds.graph.drop('halloween', false)
YIELD graphName
RETURN graphName;

// (no necesario) Confirmado que se borraron
CALL gds.graph.exists('halloween')
YIELD exists
RETURN exists;

// 1.4.2 Borrar la segunda proyeccion
CALL gds.graph.drop('halloween2', false)
YIELD graphName
RETURN graphName;

// Confirmando que se borró el otro
CALL gds.graph.exists('halloween2')
YIELD exists
RETURN exists;

// 1.4.3 Borrar la tercera proyeccion
CALL gds.graph.drop('halloween3', false)
YIELD graphName
RETURN graphName;

// Confirmando que se borró
CALL gds.graph.exists('halloween3')
YIELD exists
RETURN exists;

// 2. Degree Centrality: centralidad de las casas

CALL gds.degree.stream('halloween', {
orientation: 'REVERSE'
})
YIELD nodeId, score
WITH gds.util.asNode(nodeId) AS nodo, score
WHERE 'Casa' IN labels(nodo)
RETURN labels(nodo) AS etiquetas, nodo.direccion AS direccion, nodo.id AS id, score
ORDER BY score DESC LIMIT 10;

// Algoritmo en orientación natural, todos los puntajes dan 0
CALL gds.degree.stream('halloween', {
orientation: 'NATURAL'
})
YIELD nodeId, score
WITH gds.util.asNode(nodeId) AS nodo, score
WHERE 'Casa' IN labels(nodo)
RETURN labels(nodo) AS etiquetas, nodo.direccion AS direccion, nodo.id AS id, score
ORDER BY score DESC LIMIT 10;

// Parte 3
// 1.1 Casas compartidas (tabla)
MATCH p = ((a:Estudiante{id:"Nicolás"})-[:PIDIO_DULCES]->(c:Casa)<-[:PIDIO_DULCES]-(b:Estudiante{id:"Valentina"}))
RETURN c.direccion as Casas_compartidas_por_Nicolás_y_Valentina;

// 1.2 Casas compartidas (grafo)
MATCH p = ((e:Estudiante)-[:PIDIO_DULCES]->(c:Casa))
WHERE e.id = "Nicolás" OR e.id = "Valentina"
RETURN p

// 2. Camino más corto
MATCH (a:Estudiante {id: "Nicolás"}),(b:Estudiante {id: "Valentina"})
OPTIONAL MATCH p = shortestPath(
(a)-[:PIDIO_DULCES*1..24]-(b)
)
RETURN p, length(p) AS longitud, nodes(p) AS recorrido;

// 2.1 Explicación Apoyo
MATCH p = ((a:Estudiante{id:"Nicolás"})-[:PIDIO_DULCES]->(c:Casa)<-[:PIDIO_DULCES]-(b:Estudiante{id:"Valentina"}))
RETURN elementId(c) AS ID_CASA,c.direccion as Casas_compartidas_por_Nicolás_y_Valentina
ORDER BY ID_CASA ASC

