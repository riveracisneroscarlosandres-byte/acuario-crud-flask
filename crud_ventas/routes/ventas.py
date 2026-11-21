"""CRUD de la tabla ventas (FK a clientes, productos y vendedores).

En la base de datos el descuento se guarda como fracción (0.10 = 10 %).
En el formulario se captura como porcentaje (10) para que sea más natural.
"""
from decimal import Decimal

from flask import Blueprint, abort, flash, redirect, render_template, request, url_for

import validators as v
from db import DatabaseError, error_message, execute, query

bp = Blueprint("ventas", __name__, url_prefix="/ventas")


def _leer_formulario(form):
    errores = []
    datos = {
        "fecha": v.fecha(form, "fecha", "Fecha", errores),
        "id_cliente": v.entero(form, "id_cliente", "Cliente", errores, minimo=1),
        "id_producto": v.entero(form, "id_producto", "Producto", errores, minimo=1),
        "id_vendedor": v.entero(form, "id_vendedor", "Vendedor", errores, minimo=1),
        "cantidad": v.entero(form, "cantidad", "Cantidad", errores, minimo=1),
        "precio_unitario": v.decimal(form, "precio_unitario", "Precio unitario", errores,
                                     mayor_que=0),
        # La columna es NUMERIC(4,2): solo admite porcentajes enteros (0.10, 0.15...)
        "descuento": v.entero(form, "descuento", "Descuento (%)", errores, minimo=0),
    }
    if datos["descuento"] is not None and datos["descuento"] > 100:
        errores.append("«Descuento (%)» debe ser menor o igual a 100.")
    if datos["descuento"] is not None:
        datos["descuento"] = datos["descuento"] / Decimal(100)  # % -> fracción
    return datos, errores


def _render_form(item, titulo):
    return render_template(
        "ventas/form.html", item=item, titulo=titulo,
        clientes=query("SELECT id_cliente, nombre_cliente FROM clientes ORDER BY nombre_cliente"),
        productos=query("SELECT id_producto, nombre_producto, precio_lista "
                        "FROM productos ORDER BY nombre_producto"),
        vendedores=query("SELECT id_vendedor, nombre_vendedor FROM vendedores "
                         "ORDER BY nombre_vendedor"),
    )


@bp.route("/")
def listar():
    items = query("""
        SELECT v.*, c.nombre_cliente, p.nombre_producto, ve.nombre_vendedor,
               v.cantidad * v.precio_unitario * (1 - v.descuento) AS total
          FROM ventas v
          JOIN clientes   c  ON c.id_cliente   = v.id_cliente
          JOIN productos  p  ON p.id_producto  = v.id_producto
          JOIN vendedores ve ON ve.id_vendedor = v.id_vendedor
         ORDER BY v.fecha DESC, v.id_venta DESC
    """)
    return render_template("ventas/list.html", items=items)


@bp.route("/nuevo", methods=["GET", "POST"])
def crear():
    item = {"descuento": 0, "cantidad": 1}
    if request.method == "POST":
        item = request.form.to_dict()
        datos, errores = _leer_formulario(request.form)
        if not errores:
            try:
                execute("""INSERT INTO ventas (fecha, id_cliente, id_producto, id_vendedor,
                                               cantidad, precio_unitario, descuento)
                           VALUES (%(fecha)s, %(id_cliente)s, %(id_producto)s, %(id_vendedor)s,
                                   %(cantidad)s, %(precio_unitario)s, %(descuento)s)""",
                        datos)
                flash("Venta registrada correctamente.", "success")
                return redirect(url_for(".listar"))
            except DatabaseError as exc:
                errores.append(error_message(exc))
        for e in errores:
            flash(e, "danger")
    return _render_form(item, "Nueva venta")


@bp.route("/<int:id>/editar", methods=["GET", "POST"])
def editar(id):
    item = query("SELECT * FROM ventas WHERE id_venta = %s", (id,), one=True)
    if item is None:
        abort(404)
    item["descuento"] = int(round(item["descuento"] * 100))  # fracción -> %
    if request.method == "POST":
        item = {**item, **request.form.to_dict()}
        datos, errores = _leer_formulario(request.form)
        if not errores:
            try:
                execute("""UPDATE ventas
                              SET fecha           = %(fecha)s,
                                  id_cliente      = %(id_cliente)s,
                                  id_producto     = %(id_producto)s,
                                  id_vendedor     = %(id_vendedor)s,
                                  cantidad        = %(cantidad)s,
                                  precio_unitario = %(precio_unitario)s,
                                  descuento       = %(descuento)s
                            WHERE id_venta = %(id)s""",
                        {**datos, "id": id})
                flash("Venta actualizada correctamente.", "success")
                return redirect(url_for(".listar"))
            except DatabaseError as exc:
                errores.append(error_message(exc))
        for e in errores:
            flash(e, "danger")
    return _render_form(item, "Editar venta")


@bp.route("/<int:id>/eliminar", methods=["POST"])
def eliminar(id):
    try:
        if execute("DELETE FROM ventas WHERE id_venta = %s", (id,)):
            flash("Venta eliminada.", "success")
        else:
            flash("La venta no existe.", "warning")
    except DatabaseError as exc:
        flash(error_message(exc), "danger")
    return redirect(url_for(".listar"))
