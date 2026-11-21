"""CRUD de la tabla vendedores."""
from flask import Blueprint, abort, flash, redirect, render_template, request, url_for

import validators as v
from db import DatabaseError, error_message, execute, query

bp = Blueprint("vendedores", __name__, url_prefix="/vendedores")

ZONAS = ["Norte", "Sur", "Centro", "Oriente", "Occidente"]


def _leer_formulario(form):
    errores = []
    datos = {
        "nombre_vendedor": v.texto(form, "nombre_vendedor", "Nombre", errores, max_len=100),
        "zona": v.texto(form, "zona", "Zona", errores, max_len=30),
        "meta_mensual": v.decimal(form, "meta_mensual", "Meta mensual", errores, minimo=0),
    }
    return datos, errores


def _render_form(item, titulo):
    return render_template("vendedores/form.html", item=item, titulo=titulo, zonas=ZONAS)


@bp.route("/")
def listar():
    items = query("""
        SELECT ve.*,
               COALESCE(SUM(v.cantidad * v.precio_unitario * (1 - v.descuento)), 0) AS total_vendido
          FROM vendedores ve
          LEFT JOIN ventas v ON v.id_vendedor = ve.id_vendedor
         GROUP BY ve.id_vendedor
         ORDER BY ve.id_vendedor
    """)
    return render_template("vendedores/list.html", items=items)


@bp.route("/nuevo", methods=["GET", "POST"])
def crear():
    item = {}
    if request.method == "POST":
        item = request.form.to_dict()
        datos, errores = _leer_formulario(request.form)
        if not errores:
            try:
                execute("""INSERT INTO vendedores (nombre_vendedor, zona, meta_mensual)
                           VALUES (%(nombre_vendedor)s, %(zona)s, %(meta_mensual)s)""",
                        datos)
                flash("Vendedor creado correctamente.", "success")
                return redirect(url_for(".listar"))
            except DatabaseError as exc:
                errores.append(error_message(exc))
        for e in errores:
            flash(e, "danger")
    return _render_form(item, "Nuevo vendedor")


@bp.route("/<int:id>/editar", methods=["GET", "POST"])
def editar(id):
    item = query("SELECT * FROM vendedores WHERE id_vendedor = %s", (id,), one=True)
    if item is None:
        abort(404)
    if request.method == "POST":
        item = {**item, **request.form.to_dict()}
        datos, errores = _leer_formulario(request.form)
        if not errores:
            try:
                execute("""UPDATE vendedores
                              SET nombre_vendedor = %(nombre_vendedor)s,
                                  zona            = %(zona)s,
                                  meta_mensual    = %(meta_mensual)s
                            WHERE id_vendedor = %(id)s""",
                        {**datos, "id": id})
                flash("Vendedor actualizado correctamente.", "success")
                return redirect(url_for(".listar"))
            except DatabaseError as exc:
                errores.append(error_message(exc))
        for e in errores:
            flash(e, "danger")
    return _render_form(item, "Editar vendedor")


@bp.route("/<int:id>/eliminar", methods=["POST"])
def eliminar(id):
    try:
        if execute("DELETE FROM vendedores WHERE id_vendedor = %s", (id,)):
            flash("Vendedor eliminado.", "success")
        else:
            flash("El vendedor no existe.", "warning")
    except DatabaseError as exc:
        flash(error_message(exc), "danger")
    return redirect(url_for(".listar"))
