"""elimino la validacion de las subcategorias

Revision ID: b2fb91643f7e
Revises: e092724bb2d7
Create Date: 2025-04-29 15:26:41.275524

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'b2fb91643f7e'
down_revision: Union[str, None] = 'e092724bb2d7'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute("TRUNCATE TABLE articulos_propios RESTART IDENTITY CASCADE;")
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass
