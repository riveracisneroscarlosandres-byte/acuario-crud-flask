"""CRUD de la tabla categorias."""
from flask import Blueprint, abort, flash, redirect, render_template, request, url_for

import validators as v
from db import DatabaseError, error_message, execute, query

bp = Blueprint("categorias", __name__, url_prefix="/categorias")


def _leer_formulario(form):
    errores = []
    datos = {
        "nombre_categoria": v.texto(form, "nombre_categoria", "Nombre", errores, max_len=60),
        "descripcion": v.texto(form, "descripcion", "Descripción", errores,
                               obligatorio=False, max_len=200),
    }
    return datos, errores


@bp.route("/")
def listar():
    items = query("""
        SELECT c.*, COUNT(p.id_producto) AS num_productos
          FROM categorias c
          LEFT JOIN productos p ON p.id_categoria = c.id_categoria
         GROUP BY c.id_categoria
         ORDER BY c.id_categoria
    """)
    return render_template("categorias/list.html", items=items)


@bp.route("/nuevo", methods=["GET", "POST"])
def crear():
    item = {}
    if request.method == "POST":
        item = request.form.to_dict()
        datos, errores = _leer_formulario(request.form)
        if not errores:
            try:
                execute("INSERT INTO categorias (nombre_categoria, descripcion) VALUES (%s, %s)",
                        (datos["nombre_categoria"], datos["descripcion"]))
                flash("Categoría creada correctamente.", "success")
                return redirect(url_for(".listar"))
            except DatabaseError as exc:
                errores.append(error_message(exc))
        for e in errores:
            flash(e, "danger")
    return render_template("categorias/form.html", item=item, titulo="Nueva categoría")


@bp.route("/<int:id>/editar", methods=["GET", "POST"])
def editar(id):
    item = query("SELECT * FROM categorias WHERE id_categoria = %s", (id,), one=True)
    if item is None:
        abort(404)
    if request.method == "POST":
        item = {**item, **request.form.to_dict()}
        datos, errores = _leer_formulario(request.form)
        if not errores:
            try:
                execute("""UPDATE categorias SET nombre_categoria = %s, descripcion = %s
                            WHERE id_categoria = %s""",
                        (datos["nombre_categoria"], datos["descripcion"], id))
                flash("Categoría actualizada correctamente.", "success")
                return redirect(url_for(".listar"))
            except DatabaseError as exc:
                errores.append(error_message(exc))
        for e in errores:
            flash(e, "danger")
    return render_template("categorias/form.html", item=item, titulo="Editar categoría")


@bp.route("/<int:id>/eliminar", methods=["POST"])
def eliminar(id):
    try:
        if execute("DELETE FROM categorias WHERE id_categoria = %s", (id,)):
            flash("Categoría eliminada.", "success")
        else:
            flash("La categoría no existe.", "warning")
    except DatabaseError as exc:
        flash(error_message(exc), "danger")
    return redirect(url_for(".listar"))
