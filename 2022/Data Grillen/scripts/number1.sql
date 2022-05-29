SELECT h.SalesOrderID, d.LineTotal
FROM Sales.SalesOrderHeader h
    JOIN Sales.SalesOrderDetail d
    ON h.SalesOrderID = d.SalesOrderID
WHERE unitpricediscount = 0.30
    AND h.Status = 5