from argparse import Namespace
from dataclasses import dataclass
import typing

from klein_bottle_builder.args import CliArgs, CommandArgs, CommonArgs
from klein_bottle_builder.commands.build import build

class CliHandler(typing.Callable):
    def __call__(self, common_args : CommonArgs, command_args : CommandArgs):
        pass


@dataclass
class Handlers:
    build : CliHandler
    test : CliHandler
    publish : CliHandler

    def __getitem__(self, item):
        return getattr(self, item)

def not_implemented(*args, **kwargs):
    raise NotImplementedError()
    
default_handlers = Handlers(
    build=build,
    test=not_implemented,
    publish=not_implemented
)

def exec(raw_args : Namespace, use_handlers : Handlers = default_handlers):
    cli_args = CliArgs.from_dict(vars(raw_args))
    use_handlers[cli_args.command.command_id](cli_args, cli_args.command)
