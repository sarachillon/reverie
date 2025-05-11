"""drop table articulo nuevo y outfit nuevo

Revision ID: ab3c22d256af
Revises: e7c15aff5b7e
Create Date: 2025-05-11 08:50:13.215490

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = 'ab3c22d256af'
down_revision: Union[str, None] = 'e7c15aff5b7e'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""

    # Eliminar FKs que dependen de articulos_nuevos
    op.drop_constraint('interacciones_articulo_url_fkey', 'interacciones', type_='foreignkey')
    op.drop_column('interacciones', 'articulo_url')

    # Eliminar FKs que dependen de outfits
    op.drop_constraint('outfits_propios_id_fkey', 'outfits_propios', type_='foreignkey')

    op.drop_constraint('coleccion_outfit_outfit_id_fkey', 'coleccion_outfit', type_='foreignkey')
    op.drop_column('coleccion_outfit', 'outfit_id')

    op.drop_constraint('outfitpropio_articulo_outfit_id_fkey', 'outfitpropio_articulo', type_='foreignkey')
    op.drop_column('outfitpropio_articulo', 'outfit_id')

    # Eliminar tablas dependientes
    op.drop_table('coleccion_articulo_nuevo')
    op.drop_table('outfitnuevo_articulo')
    op.drop_table('outfits_nuevos')
    op.drop_table('articulos_nuevos')
    op.drop_index('ix_outfits_id', table_name='outfits')
    op.drop_table('outfits')

    # Reemplazar outfit_id por outfit_propio_id en las relaciones restantes
    
    op.add_column('coleccion_outfit', sa.Column('outfit_propio_id', sa.Integer(), nullable=True))
    op.create_foreign_key(None, 'coleccion_outfit', 'outfits_propios', ['outfit_propio_id'], ['id'])


    op.add_column('outfitpropio_articulo', sa.Column('outfit_propio_id', sa.Integer(), nullable=True))
    op.create_foreign_key(None, 'outfitpropio_articulo', 'outfits_propios', ['outfit_propio_id'], ['id'])

    # Añadir nuevas columnas a outfits_propios
    op.add_column('outfits_propios', sa.Column('usuario_id', sa.Integer(), nullable=True))    
    op.create_foreign_key(None, 'outfits_propios', 'usuarios', ['usuario_id'], ['id'])
    op.add_column('outfits_propios', sa.Column('titulo', sa.String(), nullable=False))
    op.add_column('outfits_propios', sa.Column('descripcion_generacion', sa.String(), nullable=True))
    op.add_column('outfits_propios', sa.Column('fecha_creacion', sa.DateTime(), nullable=False))
    op.add_column('outfits_propios', sa.Column('ocasiones', sa.ARRAY(sa.Enum('CASUAL', 'CENA', 'FORMAL', 'TRABAJO_INFORMAL', 'TRABAJO_FORMAL', 'EVENTO', name='ocasionenum')), nullable=False))
    op.add_column('outfits_propios', sa.Column('temporadas', sa.ARRAY(sa.Enum('VERANO', 'ENTRETIEMPO', 'INVIERNO', name='temporadaenum')), nullable=True))
    op.add_column('outfits_propios', sa.Column('colores', sa.ARRAY(sa.Enum('AMARILLO', 'NARANJA', 'ROJO', 'ROSA', 'VIOLETA', 'AZUL', 'VERDE', 'MARRON', 'GRIS', 'BLANCO', 'NEGRO', name='colorenum')), nullable=True))
    op.create_index(op.f('ix_outfits_propios_id'), 'outfits_propios', ['id'], unique=False)
