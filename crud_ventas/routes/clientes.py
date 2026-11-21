"""CRUD de la tabla clientes."""
from flask import Blueprint, abort, flash, redirect, render_template, request, url_for

import validators as v
from db import DatabaseError, error_message, execute, query

bp = Blueprint("clientes", __name__, url_prefix="/clientes")

SEGMENTOS = ["Persona natural", "Pyme", "Corporativo"]


def _leer_formulario(form):
    errores = []
    datos = {
        "nombre_cliente": v.texto(form, "nombre_cliente", "Nombre", errores, max_len=100),
        "ciudad": v.texto(form, "ciudad", "Ciudad", errores, max_len=60),
        "segmento": v.texto(form, "segmento", "Segmento", errores),
        "email": v.email(form, "email", "Email", errores),
    }
    if datos["segmento"] and datos["segmento"] not in SEGMENTOS:
        errores.append("Segmento no válido.")
    return datos, errores


def _render_form(item, titulo):
    return render_template("clientes/form.html", item=item, titulo=titulo, segmentos=SEGMENTOS)


@bp.route("/")
def listar():
    items = query("""
        SELECT cl.*, COUNT(v.id_venta) AS num_compras
          FROM clientes cl
          LEFT JOIN ventas v ON v.id_cliente = cl.id_cliente
         GROUP BY cl.id_cliente
         ORDER BY cl.id_cliente
    """)
    return render_template("clientes/list.html", items=items)


@bp.route("/nuevo", methods=["GET", "POST"])
def crear():
    item = {}
    if request.method == "POST":
        item = request.form.to_dict()
        datos, errores = _leer_formulario(request.form)
        if not errores:
            try:
                execute("""INSERT INTO clientes (nombre_cliente, ciudad, segmento, email)
                           VALUES (%(nombre_cliente)s, %(ciudad)s, %(segmento)s, %(email)s)""",
                        datos)
                flash("Cliente creado correctamente.", "success")
                return redirect(url_for(".listar"))
            except DatabaseError as exc:
                errores.append(error_message(exc))
        for e in errores:
            flash(e, "danger")
    return _render_form(item, "Nuevo cliente")


@bp.route("/<int:id>/editar", methods=["GET", "POST"])
def editar(id):
    item = query("SELECT * FROM clientes WHERE id_cliente = %s", (id,), one=True)
    if item is None:
        abort(404)
    if request.method == "POST":
        item = {**item, **request.form.to_dict()}
        datos, errores = _leer_formulario(request.form)
        if not errores:
            try:
                execute("""UPDATE clientes
                              SET nombre_cliente = %(nombre_cliente)s,
                                  ciudad         = %(ciudad)s,
                                  segmento       = %(segmento)s,
                                  email          = %(email)s
                            WHERE id_cliente = %(id)s""",
                        {**datos, "id": id})
                flash("Cliente actualizado correctamente.", "success")
                return redirect(url_for(".listar"))
            except DatabaseError as exc:
                errores.append(error_message(exc))
        for e in errores:
            flash(e, "danger")
    return _render_form(item, "Editar cliente")


@bp.route("/<int:id>/eliminar", methods=["POST"])
def eliminar(id):
    try:
        if execute("DELETE FROM clientes WHERE id_cliente = %s", (id,)):
            flash("Cliente eliminado.", "success")
        else:
            flash("El cliente no existe.", "warning")
    except DatabaseError as exc:
        flash(error_message(exc), "danger")
    return redirect(url_for(".listar"))
