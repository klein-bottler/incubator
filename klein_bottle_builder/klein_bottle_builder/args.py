import argparse
import typing
from dataclasses import dataclass

parser = argparse.ArgumentParser()
parser.add_argument('--verbose', action='store_const', const=True)
command = parser.add_subparsers(title='command', dest='command')

build_parser = command.add_parser('build')
build_parser.add_argument('--cache')
build_parser.add_argument('--target')
test_parser = command.add_parser('test')
test_parser.add_argument('--target')
publish_parser = command.add_parser('publish')

@dataclass
class BuildArgs:
    command_id : typing.ClassVar[str] = 'build'
    cache : str
    target : str
    def __init__(self, *, 
        cache : str,
        target : str,
        **kwargs
    ):
        self.cache = cache
        self.target = target

@dataclass
class TestArgs:
    command_id : typing.ClassVar[str] = 'test'
    target : str
    def __init__(self, *, 
        target : str,
        **kwargs
    ):
        self.target = target

@dataclass
class PublishArgs:
    command_id : typing.ClassVar[str] = 'publish'
    def __init__(self,
        **kwargs
    ):
        pass

CommandArgs = typing.Union[
    BuildArgs,
    TestArgs,
    PublishArgs
]


@dataclass
class CommonArgs:
    verbose : bool
    def __init__(self, *, verbose : bool, **kwargs):
        self.verbose = verbose

@dataclass
class CliArgs(CommonArgs):
    command : CommandArgs

    def __init__(self, common_args : dict, command_args : CommandArgs):
        super().__init__(**common_args)
        self.command = command_args
    @classmethod
    def command_args(cls) -> typing.Dict[str, any]:
        return {
            BuildArgs.command_id: BuildArgs,
            TestArgs.command_id: TestArgs,
            PublishArgs.command_id: PublishArgs,
        }
    @classmethod
    def from_dict(cls, data : typing.Dict[str, any]):
        command = data.get('command')
        command_args = cls.command_args().get(command)(**data)
        return CliArgs(data, command_args)

