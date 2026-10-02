import { Tabs } from 'expo-router'

export default function Layout() {
  return (
    <Tabs>
      <Tabs.Screen name="index" options={{ title: 'Rows A' }} />
      <Tabs.Screen name="other" options={{ title: 'Rows B' }} />
    </Tabs>
  )
}
