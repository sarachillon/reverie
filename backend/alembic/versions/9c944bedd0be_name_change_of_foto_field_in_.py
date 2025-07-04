"""name change of foto field in OutfitPropio

Revision ID: 9c944bedd0be
Revises: 4fc252196654
Create Date: 2025-05-08 08:50:47.633518

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '9c944bedd0be'
down_revision: Union[str, None] = '4fc252196654'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('outfits_propios', sa.Column('collage_key', sa.String(), nullable=False))
    op.drop_column('outfits_propios', 'foto')
    # ### end Alembic commands ###


def downgrade() -> None:
    """Downgrade schema."""
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('outfits_propios', sa.Column('foto', sa.VARCHAR(), autoincrement=False, nullable=False))
    op.drop_column('outfits_propios', 'collage_key')
    # ### end Alembic commands ###
