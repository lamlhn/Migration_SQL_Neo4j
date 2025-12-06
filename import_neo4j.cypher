// 1. Nettoyage 
MATCH (n) DETACH DELETE n;

// 2. Création des contraintes
CREATE CONSTRAINT customer_id IF NOT EXISTS FOR (u:USAGER) REQUIRE u.customer_id IS UNIQUE;
CREATE CONSTRAINT film_id IF NOT EXISTS FOR (f:FILM) REQUIRE f.film_id IS UNIQUE;
CREATE CONSTRAINT category_id IF NOT EXISTS FOR (g:GENRE) REQUIRE g.category_id IS UNIQUE;
CREATE CONSTRAINT staff_id IF NOT EXISTS FOR (e:EMPLOYE) REQUIRE e.staff_id IS UNIQUE;
CREATE CONSTRAINT store_id IF NOT EXISTS FOR (s:SECTION) REQUIRE s.store_id IS UNIQUE;

// 3. Importer les nœuds
// USAGER
WITH 'https://raw.githubusercontent.com/lamlhn/Migration_SQL_Neo4j/refs/heads/main/' AS base_url
LOAD CSV WITH HEADERS FROM base_url + 'customer.csv' AS row
CREATE (:USAGER {
    customer_id: toInteger(row.customer_id),
    first_name: row.first_name,
    last_name: row.last_name,
    active: toInteger(row.active)
});

// FILM
WITH 'https://raw.githubusercontent.com/lamlhn/Migration_SQL_Neo4j/refs/heads/main/' AS base_url
LOAD CSV WITH HEADERS FROM base_url + 'film.csv' AS row
CREATE (:FILM {
    film_id: toInteger(row.film_id),
    title: row.title,
    releaseYear: toInteger(row.releaseYear)
});

// GENRE
WITH 'https://raw.githubusercontent.com/lamlhn/Migration_SQL_Neo4j/refs/heads/main/' AS base_url
LOAD CSV WITH HEADERS FROM base_url + 'categorie.csv' AS row
CREATE (:GENRE {
    category_id: toInteger(row.category_id),
    categoryName: row.categoryName
});


// EMPLOYE
WITH 'https://raw.githubusercontent.com/lamlhn/Migration_SQL_Neo4j/refs/heads/main/' AS base_url
LOAD CSV WITH HEADERS FROM base_url + 'staff.csv' AS row
CREATE (:EMPLOYE {
    staff_id: toInteger(row.staff_id),
    first_name: row.first_name,
    last_name: row.last_name,
    active: toInteger(row.active)
});

// SECTION
WITH 'https://raw.githubusercontent.com/lamlhn/Migration_SQL_Neo4j/refs/heads/main/' AS base_url
LOAD CSV WITH HEADERS FROM base_url + 'store.csv' AS row
CREATE (:SECTION {
    store_id: toInteger(row.store_id)
});

// 4. Importer les relations
// (USAGER) -[:A_VISIONNE]-> (FILM)
WITH 'https://raw.githubusercontent.com/lamlhn/Migration_SQL_Neo4j/refs/heads/main/' AS base_url
LOAD CSV WITH HEADERS FROM base_url + 'a_visionne.csv' AS row
MATCH (u:USAGER {customer_id: toInteger(row.customer_id)})
MATCH (f:FILM {film_id: toInteger(row.film_id)})
CREATE (u)-[:A_VISIONNE {
    rental_id: toInteger(row.rental_id),
    rental_date: datetime(replace(row.rental_date, ' ', 'T')),
    return_date: CASE WHEN row.return_date IS NOT NULL THEN datetime(replace(row.return_date, ' ', 'T')) ELSE null END
}]->(f);

// (FILM) -[:APPARTIENT_A]-> (GENRE)
WITH 'https://raw.githubusercontent.com/lamlhn/Migration_SQL_Neo4j/refs/heads/main/' AS base_url
LOAD CSV WITH HEADERS FROM base_url + 'appartient_a.csv' AS row
MATCH (f:FILM {film_id: toInteger(row.film_id)})
MATCH (g:GENRE {category_id: toInteger(row.category_id)})
CREATE (f)-[:APPARTIENT_A]->(g);

// (EMPLOYE) -[:TRAVAILLE_DANS]-> (SECTION)
WITH 'https://raw.githubusercontent.com/lamlhn/Migration_SQL_Neo4j/refs/heads/main/' AS base_url
LOAD CSV WITH HEADERS FROM base_url + 'travaille_dans.csv' AS row
MATCH (e:EMPLOYE {staff_id: toInteger(row.staff_id)})
MATCH (s:SECTION {store_id: toInteger(row.store_id)})
CREATE (e)-[:TRAVAILLE_DANS]->(s);

// (EMPLOYE) -[:SUPERVISE_PAR]-> (EMPLOYE)
WITH 'https://raw.githubusercontent.com/lamlhn/Migration_SQL_Neo4j/refs/heads/main/' AS base_url
LOAD CSV WITH HEADERS FROM base_url + 'supervise_par.csv' AS row
MATCH (e:EMPLOYE {staff_id: toInteger(row.staff_id)})
MATCH (m:EMPLOYE {staff_id: toInteger(row.manager_id)})
CREATE (e)-[:SUPERVISE_PAR]->(m);

// 9. Validation des imports
MATCH (n) RETURN labels(n) as label, count(*) as count
ORDER BY label;

// 10. Validation des relations
MATCH ()-[r]->() RETURN type(r) as relation, count(*) as count
ORDER BY relation;
