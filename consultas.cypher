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



// 4. Visitas sin dulces

// 4.1 Query visitas sin dulces



// 4.2 Obteniendo la cantidad de visitas sin dulces y porcentaje con relación a todas las visitas

MATCH (:Estudiante)-[r:PIDIO_DULCES]->(:Casa)
WITH count(r) AS total // guarda el total de visitas

MATCH (:Estudiante)-[r:PIDIO_DULCES]->(:Casa)
WHERE r.cantidad = 0 
WITH count(r) AS cant_visitas_sin_dulces, total //guarda las visitas sin dulces

RETURN cant_visitas_sin_dulces,100*(cant_visitas_sin_dulces)/(total) AS Porcentaje;
