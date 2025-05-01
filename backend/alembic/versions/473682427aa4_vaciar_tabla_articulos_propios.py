"""vaciar_tabla_articulos_propios

Revision ID: 473682427aa4
Revises: fc41129eb667
Create Date: 2025-04-29 13:26:50.102606

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '473682427aa4'
down_revision: Union[str, None] = 'fc41129eb667'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass
