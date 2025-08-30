import json
import argparse
from jinja2 import Environment, PackageLoader, select_autoescape
from pathlib import Path


class JsonToNativeObject:
    def __init__(self, filename, template, libraryName, saveTo):
        self.filename = filename
        self.env = Environment(
            loader=PackageLoader("tono", "templates"),
            autoescape=select_autoescape()
        )
        self.template = self.env.get_template(template)
        self.clazzes = []
        self.libraryName = libraryName
        self.saveTo = saveTo

    def _toCamelCase(self, string):
        """Changes the input [string] to a camel case format.

        Args:
            string: A string in snake_case format

        Returns:
            A String in camelCase format
        """
        return "".join(x.capitalize() for x in string.lower().split("_"))

    def _toLowerCamelCase(self, string):
        """Changes the input [string] to a lower camel case format.

        Args:
            string: A string in snake_case format

        Returns:
            A String in camelCase format
        """
        camel_str = self._toCamelCase(string)
        return string[0].lower() + camel_str[1:]

    def _toUpperCamelCase(self, string):
        """Changes the input [string] to a camel case format.

        Args:
            string: A string in snake_case format

        Returns:
            A String in CamelCase format
        """
        camel_str = self._toCamelCase(string)
        return string[0].upper() + camel_str[1:] + "Response"

    def _parseJsons(self, json):
        pass

    def find_dependencies(self, obj, dependencies=None):
        """Recursively find child objects"""
        if dependencies is None:
            dependencies = []

        if isinstance(obj, dict):
            for key, value in obj.items():
                if isinstance(value, dict) and type(value) == dict:
                    dependencies.append(key)
                    self.clazzes.append(self.generate_clazz(key, value))
                elif isinstance(value, list):
                    child = value[0]
                    if isinstance(child, dict):
                        dependencies.append(key)
                        self.clazzes.append(self.generate_clazz(key, child))

                self.find_dependencies(value, dependencies)
        elif isinstance(obj, list):
            for item in obj:
                self.find_dependencies(item, dependencies)

        return dependencies

    def extract_attrs(self, obj, attrs=None):
        """Extract primitive attributes"""
        if attrs is None:
            attrs = []

        if isinstance(obj, dict):
            for key, value in obj.items():
                if not isinstance(value, (dict, list)):
                    attrs.append({
                        'name': self._toLowerCamelCase(key),
                        'type': self.resolve_type(key, value),
                        'jsonName': key
                    })
                elif isinstance(value, dict):
                    attrs.append({
                        'name': self._toLowerCamelCase(key),
                        'type': self.resolve_type(key, value),
                        'jsonName': key
                    })
                elif isinstance(value, list):
                    childType = self.resolve_type(key, value[0])

                    attrs.append({
                        'name': self._toLowerCamelCase(key),
                        'type': f'List<{childType}>',
                        'jsonName': key
                    })

        return attrs

    def resolve_type(self, key, value):
        match type(value).__name__:
            case 'int':
                return "int"
            case 'dict':
                return self._toUpperCamelCase(key)
            case 'str':
                return "String"
            case 'bool':
                return "bool"
            case _:
                return "String"

    def generate_clazz(self, name, obj):
        return {
            'filename': name,
            'name': self._toUpperCamelCase(name),
            'fromJson': self._toUpperCamelCase(name) + 'FromJson',
            'toJson': self._toUpperCamelCase(name) + 'ToJson',
            'dependencies': self.find_dependencies(obj),
            'attrs': self.extract_attrs(obj),
            'libraryName': self.libraryName,
            'saveTo': self.saveTo
        }

    def render(self, obj=None):
        if (obj == None):
            obj = self.filename

        with open(obj) as f:
            name = obj.split('/')[-1].split('.')[0]
            jsonFile = json.load(f)

            self.clazzes.append(self.generate_clazz(name, jsonFile))

            for clazz in self.clazzes:
                Path(clazz["saveTo"]).mkdir(parents=True, exist_ok=True)

                with open(f'{clazz["saveTo"]}/{clazz["filename"]}_response.dart', 'w') as n:
                    n.write(self.template.render(clazz=clazz))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Generate Flutter test file from a JSON."
    )
    parser.add_argument("jsonName", help="Name of the JSON file to use")
    parser.add_argument("--template", default="flutter-test.jinja",
                        help="Jinja template file \
                        (default: flutter-test.jinja)")
    parser.add_argument("packageName", help="Name of your Dart package")
    parser.add_argument("--saveTo", default=".",
                        help="Directory to save the output \
                        (default: current directory)")

    args = parser.parse_args()

    # Ensure save path exists
    jsonToNativeObject = JsonToNativeObject(
        args.jsonName,
        args.template,
        args.packageName,
        args.saveTo,
    )
    jsonToNativeObject.render()

    outputName = f"{args.saveTo}/{args.jsonName.split('.')[0]}.dart"
