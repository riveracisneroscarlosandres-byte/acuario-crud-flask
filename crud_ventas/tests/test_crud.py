"""Pruebas de punta a punta del CRUD contra la base ventas_db real.

Cada prueba crea sus propios registros y los elimina al final,
así que los 10 registros originales de cada tabla no se modifican.

Ejecutar con:  python -m pytest -v
"""
import psycopg2
import pytest

from app import create_app
from config import Config

PREFIJO = "ZZ_TEST_"


@pytest.fixture()
def client():
    app = create_app()
    app.config["TESTING"] = True
    with app.test_client() as c:
        yield c


def sql(consulta, params=()):
    conn = psycopg2.connect(host=Config.DB_HOST, port=Config.DB_PORT, dbname=Config.DB_NAME,
                            user=Config.DB_USER, password=Config.DB_PASSWORD)
    with conn, conn.cursor() as cur:
        cur.execute(consulta, params)
        resultado = cur.fetchone() if cur.description else None
    conn.close()
    return resultado


def contar(tabla):
    return sql(f"SELECT COUNT(*) FROM {tabla}")[0]


# ---------------------------------------------------------------- páginas

@pytest.mark.parametrize("ruta", ["/", "/categorias/", "/productos/", "/clientes/",
                                  "/vendedores/", "/ventas/", "/categorias/nuevo",
                                  "/productos/nuevo", "/clientes/nuevo", "/vendedores/nuevo",
                                  "/ventas/nuevo", "/categorias/1/editar", "/productos/1/editar",
                                  "/clientes/1/editar", "/vendedores/1/editar",
                                  "/ventas/1/editar"])
def test_paginas_cargan(client, ruta):
    assert client.get(ruta).status_code == 200


def test_registro_inexistente_da_404(client):
    assert client.get("/productos/999999/editar").status_code == 404


def test_listados_muestran_datos(client):
    assert "Portátil Lenovo IdeaPad 5" in client.get("/productos/").get_data(as_text=True)
    assert "Laura Gómez Rojas" in client.get("/ventas/").get_data(as_text=True)


# ---------------------------------------------------------------- categorias

def test_crud_categorias(client):
    antes = contar("categorias")
    r = client.post("/categorias/nuevo", data={"nombre_categoria": PREFIJO + "Cat",
                                               "descripcion": "prueba"}, follow_redirects=True)
    assert "Categoría creada" in r.get_data(as_text=True)
    id_ = sql("SELECT id_categoria FROM categorias WHERE nombre_categoria=%s", (PREFIJO + "Cat",))[0]

    r = client.post(f"/categorias/{id_}/editar", data={"nombre_categoria": PREFIJO + "Cat2",
                                                       "descripcion": ""}, follow_redirects=True)
    assert "actualizada" in r.get_data(as_text=True)
    assert sql("SELECT nombre_categoria, descripcion FROM categorias WHERE id_categoria=%s",
               (id_,)) == (PREFIJO + "Cat2", None)

    r = client.post(f"/categorias/{id_}/eliminar", follow_redirects=True)
    assert "eliminada" in r.get_data(as_text=True)
    assert contar("categorias") == antes


def test_categoria_duplicada_y_vacia(client):
    r = client.post("/categorias/nuevo", data={"nombre_categoria": "Computadores"})
    assert "Ya existe un registro" in r.get_data(as_text=True)
    r = client.post("/categorias/nuevo", data={"nombre_categoria": "  "})
    assert "es obligatorio" in r.get_data(as_text=True)


def test_no_elimina_categoria_con_productos(client):
    r = client.post("/categorias/1/eliminar", follow_redirects=True)
    assert "relacionado" in r.get_data(as_text=True)
    assert sql("SELECT COUNT(*) FROM categorias WHERE id_categoria=1")[0] == 1


# ---------------------------------------------------------------- productos

def test_crud_productos(client):
    datos = {"nombre_producto": PREFIJO + "Prod", "id_categoria": "3",
             "precio_lista": "12345.50", "stock": "7"}
    r = client.post("/productos/nuevo", data=datos, follow_redirects=True)
    assert "Producto creado" in r.get_data(as_text=True)
    id_ = sql("SELECT id_producto FROM productos WHERE nombre_producto=%s", (PREFIJO + "Prod",))[0]

    r = client.post(f"/productos/{id_}/editar",
                    data={**datos, "precio_lista": "999", "stock": "0"}, follow_redirects=True)
    assert "actualizado" in r.get_data(as_text=True)
    precio, stock = sql("SELECT precio_lista, stock FROM productos WHERE id_producto=%s", (id_,))
    assert float(precio) == 999 and stock == 0

    client.post(f"/productos/{id_}/eliminar")
    assert sql("SELECT COUNT(*) FROM productos WHERE id_producto=%s", (id_,))[0] == 0


def test_producto_valores_invalidos(client):
    r = client.post("/productos/nuevo", data={"nombre_producto": "X", "id_categoria": "",
                                              "precio_lista": "-5", "stock": "abc"})
    html = r.get_data(as_text=True)
    assert "Categoría" in html and "mayor que 0" in html and "número entero" in html


def test_producto_con_categoria_inexistente(client):
    r = client.post("/productos/nuevo", data={"nombre_producto": PREFIJO + "X",
                                              "id_categoria": "999999", "precio_lista": "1",
                                              "stock": "1"})
    assert "relacionado" in r.get_data(as_text=True)


# ---------------------------------------------------------------- clientes

def test_crud_clientes(client):
    datos = {"nombre_cliente": PREFIJO + "Cli", "ciudad": "Neiva", "segmento": "Pyme",
             "email": "zz_test@ejemplo.co"}
    r = client.post("/clientes/nuevo", data=datos, follow_redirects=True)
    assert "Cliente creado" in r.get_data(as_text=True)
    id_ = sql("SELECT id_cliente FROM clientes WHERE nombre_cliente=%s", (PREFIJO + "Cli",))[0]

    r = client.post(f"/clientes/{id_}/editar",
                    data={**datos, "segmento": "Corporativo", "email": ""}, follow_redirects=True)
    assert "actualizado" in r.get_data(as_text=True)
    assert sql("SELECT segmento, email FROM clientes WHERE id_cliente=%s",
               (id_,)) == ("Corporativo", None)

    client.post(f"/clientes/{id_}/eliminar")
    assert sql("SELECT COUNT(*) FROM clientes WHERE id_cliente=%s", (id_,))[0] == 0


def test_cliente_email_duplicado_y_segmento_invalido(client):
    r = client.post("/clientes/nuevo", data={"nombre_cliente": "X", "ciudad": "Neiva",
                                             "segmento": "Pyme",
                                             "email": "laura.gomez@mail.com"})
    assert "Ya existe un registro" in r.get_data(as_text=True)
    r = client.post("/clientes/nuevo", data={"nombre_cliente": "X", "ciudad": "Neiva",
                                             "segmento": "Otro", "email": "malo"})
    html = r.get_data(as_text=True)
    assert "Segmento no válido" in html and "formato válido" in html


def test_no_elimina_cliente_con_ventas(client):
    r = client.post("/clientes/1/eliminar", follow_redirects=True)
    assert "relacionado" in r.get_data(as_text=True)


# ---------------------------------------------------------------- vendedores

def test_crud_vendedores(client):
    datos = {"nombre_vendedor": PREFIJO + "Ven", "zona": "Sur", "meta_mensual": "1500000"}
    r = client.post("/vendedores/nuevo", data=datos, follow_redirects=True)
    assert "Vendedor creado" in r.get_data(as_text=True)
    id_ = sql("SELECT id_vendedor FROM vendedores WHERE nombre_vendedor=%s", (PREFIJO + "Ven",))[0]

    r = client.post(f"/vendedores/{id_}/editar", data={**datos, "zona": "Norte"},
                    follow_redirects=True)
    assert "actualizado" in r.get_data(as_text=True)
    assert sql("SELECT zona FROM vendedores WHERE id_vendedor=%s", (id_,))[0] == "Norte"

    client.post(f"/vendedores/{id_}/eliminar")
    assert sql("SELECT COUNT(*) FROM vendedores WHERE id_vendedor=%s", (id_,))[0] == 0


# ---------------------------------------------------------------- ventas

def test_crud_ventas(client):
    antes = contar("ventas")
    datos = {"fecha": "2026-10-23", "id_cliente": "2", "id_producto": "4", "id_vendedor": "3",
             "cantidad": "3", "precio_unitario": "980000", "descuento": "10"}
    r = client.post("/ventas/nuevo", data=datos, follow_redirects=True)
    assert "Venta registrada" in r.get_data(as_text=True)
    id_, desc = sql("SELECT id_venta, descuento FROM ventas ORDER BY id_venta DESC LIMIT 1")
    assert float(desc) == 0.10  # 10 % se guarda como 0.10

    # el formulario de edición muestra el descuento como porcentaje
    assert 'value="10"' in client.get(f"/ventas/{id_}/editar").get_data(as_text=True)

    r = client.post(f"/ventas/{id_}/editar", data={**datos, "cantidad": "5", "descuento": "15"},
                    follow_redirects=True)
    assert "actualizada" in r.get_data(as_text=True)
    cant, desc = sql("SELECT cantidad, descuento FROM ventas WHERE id_venta=%s", (id_,))
    assert cant == 5 and float(desc) == 0.15

    # 12.5 % no cabe en NUMERIC(4,2): se rechaza en lugar de redondearse en silencio
    r = client.post(f"/ventas/{id_}/editar", data={**datos, "descuento": "12.5"})
    assert "número entero" in r.get_data(as_text=True)

    client.post(f"/ventas/{id_}/eliminar")
    assert contar("ventas") == antes


def test_venta_invalida(client):
    r = client.post("/ventas/nuevo", data={"fecha": "", "id_cliente": "1", "id_producto": "1",
                                           "id_vendedor": "1", "cantidad": "0",
                                           "precio_unitario": "100", "descuento": "150"})
    html = r.get_data(as_text=True)
    assert "«Fecha» es obligatorio" in html and "mayor o igual a 1" in html and "menor o igual a 100" in html


def test_eliminar_inexistente(client):
    r = client.post("/ventas/999999/eliminar", follow_redirects=True)
    assert "no existe" in r.get_data(as_text=True)


# ---------------------------------------------------------------- integridad final

def test_datos_originales_intactos():
    for tabla in ["categorias", "productos", "clientes", "vendedores", "ventas"]:
        assert contar(tabla) == 10, tabla
