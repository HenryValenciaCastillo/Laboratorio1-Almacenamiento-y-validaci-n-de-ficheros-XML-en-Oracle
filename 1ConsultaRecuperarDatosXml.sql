-- Consulta para recuperar datos en formato XML uniendo 2 tablas (departments y employees)
SELECT 
  XMLELEMENT("Departamento",
    XMLATTRIBUTES(d.department_id AS "id"),
    XMLFOREST(d.department_name AS "nombre_depto"),
    XMLELEMENT("Empleados",
      XMLAGG(
        XMLELEMENT("Empleado",
          XMLFOREST(e.first_name AS "nombre", e.last_name AS "apellido")
        )
      )
    )
  ).getClobVal() AS resultado_xml
FROM departments d
JOIN employees e ON d.department_id = e.department_id
WHERE d.department_id = 10
GROUP BY d.department_id, d.department_name;