#!/usr/bin/env python
"""CLI para lanzar la generación de outfits vía API.

Ejecuta directamente el endpoint `/generar` del backend FastAPI para
poder probar la lógica sin necesidad de frontend.

Requisitos
~~~~~~~~~~
1. Instala dependencias:
   pip install httpx[cli] typer rich
2. Define tu token de autenticación (o cookie) en una variable de
   entorno `AUTH_TOKEN`, o pásalo como parámetro `--token`.

Uso básico (token Bearer):
    python generar_outfit_cli.py \
        --api http://localhost:8000 \
        --token eyJhbGciOi... \
        --titulo "Look rápido" \
        --descripcion "Prueba sin frontend" \
        --ocasiones CASUAL \
        --temporadas PRIMAVERA VERANO \
        --colores AZUL BLANCO

Notas
~~~~~
* Las listas se pasan simplemente separando valores.
* Si necesitas usar cookie de sesión en lugar de token, añade `--cookie
  "session=..."`.
* El script muestra la URL firmada del collage y de cada artículo para
  que puedas abrir las imágenes en un navegador.
"""
from __future__ import annotations

import asyncio
import os
from typing import List, Optional

import httpx
import typer
from rich import print
from rich.panel import Panel
from rich.pretty import Pretty

app = typer.Typer(add_completion=False, rich_markup_mode="rich")


@app.command()
def main(
    titulo: str = typer.Option(..., help="Título del outfit"),
    descripcion: Optional[str] = typer.Option(None, help="Descripción opcional"),
    ocasiones: List[str] = typer.Option(..., help="Ocasiones (enum names)", show_default=False),
    temporadas: List[str] = typer.Option([], help="Temporadas (enum names)"),
    colores: List[str] = typer.Option([], help="Colores (enum names)"),
    api: str = typer.Option("http://localhost:8000", help="URL base del backend"),
    token: Optional[str] = typer.Option(os.getenv("AUTH_TOKEN"), help="Token Bearer"),
    cookie: Optional[str] = typer.Option(None, help="Cookie completa p.ej. 'session=abc'"),
    timeout: float = typer.Option(30.0, help="Timeout petición"),
):
    """Llama al endpoint `/generar` y muestra el resultado prettificado."""

    async def _run():
        headers = {}
        cookies = {}
        if token:
            headers["Authorization"] = f"Bearer {token}"
        if cookie:
            # permite pasar varias cookies separadas por ;
            cookies = {k: v for k, v in (c.strip().split("=", 1) for c in cookie.split(";"))}

        data = {
            "titulo": titulo,
            "descripcion": descripcion or "",
            "ocasiones[]": ocasiones,
            "temporadas[]": temporadas,
            "colores[]": colores,
        }

        async with httpx.AsyncClient(base_url=api, timeout=timeout, headers=headers, cookies=cookies) as client:
            try:
                r = await client.post("/generar", data=data)
            except httpx.HTTPError as exc:
                print(f"[bold red]Error de conexión:[/] {exc}")
                raise typer.Exit(1)

        if r.status_code != 200:
            print(Panel.fit(str(r.text), title=f"Error {r.status_code}", border_style="red"))
            raise typer.Exit(1)

        outfit = r.json()
        print(Panel.fit(Pretty(outfit, indent_guides=True), title="Outfit generado", border_style="green"))
        if collage := outfit.get("imagen"):
            print(f"[bold]Collage:[/] {collage}")
        for art in outfit.get("articulos_propios", []):
            print(f"- {art.get('nombre', art.get('id'))}: {art.get('urlFirmada')}")

    asyncio.run(_run())


if __name__ == "__main__":
    app()
