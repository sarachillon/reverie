"""seguidores

Revision ID: c2f3b1033281
Revises: 1775df73146f
Create Date: 2025-05-12 15:55:54.940044

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'c2f3b1033281'
down_revision: Union[str, None] = '1775df73146f'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('seguidores',
    sa.Column('seguido_id', sa.Integer(), nullable=False),
    sa.Column('seguidor_id', sa.Integer(), nullable=False),
    sa.ForeignKeyConstraint(['seguido_id'], ['usuarios.id'], ),
    sa.ForeignKeyConstraint(['seguidor_id'], ['usuarios.id'], ),
    sa.PrimaryKeyConstraint('seguido_id', 'seguidor_id')
    )
    # ### end Alembic commands ###


def downgrade() -> None:
    """Downgrade schema."""
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_table('seguidores')
    # ### end Alembic commands ###
