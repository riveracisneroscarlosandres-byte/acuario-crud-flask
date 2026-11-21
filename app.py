"""Punto de entrada de la aplicación CRUD ventas_db."""
import psycopg2
from flask import Flask, render_template

import db
from config import Config
from routes.categorias import bp as categorias_bp
from routes.clientes import bp as clientes_bp
from routes.productos import bp as productos_bp
from routes.vendedores import bp as vendedores_bp
from routes.ventas import bp as ventas_bp


def formato_pesos(valor):
    """Filtro Jinja: 3200000 -> $ 3.200.000"""
    if valor is None:
        return ""
    return "$ " + f"{float(valor):,.0f}".replace(",", ".")


def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)

    db.init_app(app)
    app.add_template_filter(formato_pesos, "pesos")

    for bp in (categorias_bp, productos_bp, clientes_bp, vendedores_bp, ventas_bp):
        app.register_blueprint(bp)

    @app.route("/")
    def inicio():
        conteos = db.query("""
            SELECT (SELECT COUNT(*) FROM categorias) AS categorias,
                   (SELECT COUNT(*) FROM productos)  AS productos,
                   (SELECT COUNT(*) FROM clientes)   AS clientes,
                   (SELECT COUNT(*) FROM vendedores) AS vendedores,
                   (SELECT COUNT(*) FROM ventas)     AS ventas,
                   (SELECT COALESCE(SUM(cantidad * precio_unitario * (1 - descuento)), 0)
                      FROM ventas) AS total_ventas
        """, one=True)
        return render_template("index.html", c=conteos)

    @app.errorhandler(psycopg2.OperationalError)
    def error_conexion(exc):
        return render_template("error_db.html", error=str(exc)), 500

    @app.errorhandler(404)
    def no_encontrado(exc):
        return render_template("404.html"), 404

    return app


app = create_app()

if __name__ == "__main__":
    # En macOS el puerto 5000 lo ocupa "Receptor AirPlay", por eso usamos 5001
    app.run(debug=True, port=5001)
