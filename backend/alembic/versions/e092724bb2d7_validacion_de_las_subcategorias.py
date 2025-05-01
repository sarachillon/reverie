"""validacion de las subcategorias

Revision ID: e092724bb2d7
Revises: 83f69b3b050f
Create Date: 2025-04-29 13:31:30.627277

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'e092724bb2d7'
down_revision: Union[str, None] = '83f69b3b050f'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass
