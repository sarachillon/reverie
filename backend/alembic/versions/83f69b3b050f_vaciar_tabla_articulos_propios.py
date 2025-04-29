"""vaciar_tabla_articulos_propios

Revision ID: 83f69b3b050f
Revises: 473682427aa4
Create Date: 2025-04-29 13:28:37.693759

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '83f69b3b050f'
down_revision: Union[str, None] = '473682427aa4'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute("TRUNCATE TABLE articulos_propios RESTART IDENTITY CASCADE;")
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass
