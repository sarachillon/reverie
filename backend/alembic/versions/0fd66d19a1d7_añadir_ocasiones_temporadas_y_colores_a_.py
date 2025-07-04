"""Añadir ocasiones, temporadas y colores a ArticuloPropio

Revision ID: 0fd66d19a1d7
Revises: 921a76accc85
Create Date: 2025-04-26 12:03:54.557418

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '0fd66d19a1d7'
down_revision: Union[str, None] = '921a76accc85'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('articulos_propios', sa.Column('ocasiones', sa.ARRAY(sa.Enum('CASUAL', 'CENA', 'FORMAL', 'TRABAJO_INFORMAL', 'TRABAJO_FORMAL', 'EVENTO', name='ocasionenum')), nullable=False))
    op.add_column('articulos_propios', sa.Column('temporadas', sa.ARRAY(sa.Enum('VERANO', 'ENTRETIEMPO', 'INVIERNO', name='temporadaenum')), nullable=False))
    op.add_column('articulos_propios', sa.Column('colores', sa.ARRAY(sa.Enum('AMARILLO', 'NARANJA', 'ROJO', 'ROSA', 'VIOLETA', 'AZUL', 'VERDE', 'MARRON', 'GRIS', 'BLANCO', 'NEGRO', name='colorenum')), nullable=False))
    op.add_column('outfits', sa.Column('ocasiones', sa.ARRAY(sa.Enum('CASUAL', 'CENA', 'FORMAL', 'TRABAJO_INFORMAL', 'TRABAJO_FORMAL', 'EVENTO', name='ocasionenum')), nullable=False))
    # ### end Alembic commands ###


def downgrade() -> None:
    """Downgrade schema."""
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('outfits', 'ocasiones')
    op.drop_column('articulos_propios', 'colores')
    op.drop_column('articulos_propios', 'temporadas')
    op.drop_column('articulos_propios', 'ocasiones')
    # ### end Alembic commands ###
